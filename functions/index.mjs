import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import { onRequest } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import axios from 'axios';
import fs from 'fs';
import path from 'path';

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

async function storeNotification(userId, notification) {
  const notificationsRef = db.collection(`users/${userId}/notifications`);
  const notificationId = notificationsRef.doc().id;
  await notificationsRef.doc(notificationId).set({
    ...notification,
    notificationId,
    timestamp: FieldValue.serverTimestamp(),
  });

  const snapshot = await notificationsRef.orderBy('timestamp').limit(11).get();
  if (snapshot.size > 10) {
    const oldestDoc = snapshot.docs[0];
    await oldestDoc.ref.delete();
  }
}

async function sendPushNotification(userId, notification) {
  const userDoc = await db.doc(`users/${userId}`).get();
  const userData = userDoc.data();
  const userFcmToken = userData?.fcmToken;

  if (userFcmToken) {
    await messaging.send({
      token: userFcmToken,
      notification: {
        title: notification.title,
        body: notification.message,
      },
      data: notification.data || {},
    });
    console.log(`Push notification sent to user ${userId}`);
  } else {
    console.log(`No FCM token found for user ${userId}`);
  }
}

export const sendFollowNotification = onDocumentUpdated("users/{userId}", async (event) => {
  const userId = event.params.userId;

  const beforeData = event.data.before.data();
  const afterData = event.data.after.data();

  const oldFollowers = beforeData?.followers || [];
  const newFollowers = afterData?.followers || [];

  const newFollowerIds = newFollowers.filter((id) => !oldFollowers.includes(id));

  if (newFollowerIds.length === 0) {
    return null;
  }

  try {
    for (const followerId of newFollowerIds) {
      const followerDoc = await db.doc(`users/${followerId}`).get();
      const followerData = followerDoc.data();
      const followerName = followerData?.username;

      const notification = {
        message: `${followerName} is now following you!`,
        type: "new_follower",
        followerId,
        title: "New follower!",
        data: { screen: 'notifications' }
      };

      await storeNotification(userId, notification);
      await sendPushNotification(userId, notification);
    }
  } catch (error) {
    console.error("Error processing follow notification:", error);
  }

  return null;
});

export const sendReviewNotification = onDocumentCreated("reviews/{reviewId}", async (event) => {
  const reviewData = event.data.data();
  const reviewAuthorId = reviewData.userId;

  try {
    const reviewAuthorDoc = await db.doc(`users/${reviewAuthorId}`).get();
    const reviewAuthorData = reviewAuthorDoc.data();
    const reviewAuthorName = reviewAuthorData.username;

    const followers = reviewAuthorData.followers || [];

    if (followers.length === 0) {
      return null;
    }

    for (const followerId of followers) {
      const notification = {
        message: `${reviewAuthorName} just posted a new review!`,
        type: "new_review",
        reviewAuthorId,
        reviewAuthorName,
        title: "New review posted!",
        data: { screen: 'notifications' }
      };

      await storeNotification(followerId, notification);
      await sendPushNotification(followerId, notification);
    }
  } catch (error) {
    console.error("Error sending review notification: ", error);
  }
  return null;
});

export const getSharedWatchlist = onRequest(async (request, response) => {
  response.set('Access-Control-Allow-Origin', '*');
  
  if (request.method === 'OPTIONS') {
    response.set('Access-Control-Allow-Methods', 'GET');
    response.set('Access-Control-Allow-Headers', 'Content-Type');
    response.set('Access-Control-Max-Age', '3600');
    response.status(204).send('');
    return;
  }

  const watchlistId = request.query.watchlistId;
  const userId = request.query.userId;
  const invitedBy = request.query.invitedBy;

  if (!watchlistId || !userId || !invitedBy) {
    response.status(400).send('Missing watchlistId or userId');
    return;
  }

  try {
    const watchlistDoc = await db
      .collection('users').doc(userId)
      .collection('my_watchlists').doc(watchlistId)
      .get();

    if (!watchlistDoc.exists) {
      response.status(404).send('Watchlist not found');
      return;
    }

    const watchlistData = watchlistDoc.data();

    if (watchlistData.isPrivate) {
      response.status(403).send('This watchlist is private');
      return;
    }

    const userDoc = await db
      .collection('users').doc(userId)
      .get();

    if (!userDoc.exists) {
      response.status(404).send('User not found');
      return;
    }

    const userData = userDoc.data();

    const sharedByDoc = await db
      .collection('users').doc(invitedBy)
      .get();

    if (!sharedByDoc.exists) {
      response.status(404).send('User not found');
      return;
    }

    const sharedByData = sharedByDoc.data();

    const responseData = {
      watchlist: {
        id: watchlistDoc.id,
        name: watchlistData.name,
        createdAt: watchlistData.createdAt,
        updatedAt: watchlistData.updatedAt,
      },
      user: {
        username: userData.username,
        name: userData.name,
        profilePicture: userData.profilePicture,
      },
      sharedBy: {
        username: sharedByData.username,
        name: sharedByData.name,
        profilePicture: sharedByData.profilePicture,
      },
    };

    response.status(200).json(responseData);
  } catch (error) {
    console.error('Error retrieving watchlist:', error);
    response.status(500).send('Internal server error');
  }
});

const keyFilePath = path.join(__dirname, 'key.json');
const apiKeyData = JSON.parse(fs.readFileSync(keyFilePath, 'utf-8'));
const apiKey = apiKeyData.apiKey;

async function fetchMoviesReleasingTomorrow() {
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  const releaseDate = tomorrow.toISOString().split('T')[0];

  try {
    const response = await axios.get(`https://api.themoviedb.org/3/discover/movie?api_key=${apiKey}&primary_release_date.gte=${releaseDate}&primary_release_date.lte=${releaseDate}`);
    return response.data.results;
  } catch (error) {
    console.error("Error fetching movies releasing tomorrow:", error);
    throw error;
  }
}

export const sendReleaseNotifications = onSchedule({
  schedule: 'every day 12:00',
  timezone: "Europe/Paris"
}, async (event) => {
  try {
    const moviesReleasingTomorrow = await fetchMoviesReleasingTomorrow();

    if (moviesReleasingTomorrow.length === 0) {
      console.log("No movies are releasing tomorrow.");
      return null;
    }

    const movieIdsReleasingTomorrow = moviesReleasingTomorrow.map(movie => movie.id);

    const usersSnapshot = await db.collection('users').get();

    usersSnapshot.forEach(async (userDoc) => {
      const userData = userDoc.data();
      const likedMovies = userData.likedMovies || [];

      const matchingMovies = likedMovies.filter(movieId => movieIdsReleasingTomorrow.includes(movieId));

      if (matchingMovies.length === 0) {
        return;
      }

      for (const movieId of matchingMovies) {
        const movieDetails = moviesReleasingTomorrow.find(movie => movie.id === movieId);

        if (movieDetails) {
          const notification = {
            message: `The movie '${movieDetails.title}' you liked is releasing tomorrow!`,
            type: "movie_release",
            movieId,
            movieTitle: movieDetails.title,
            title: "Movie Release Alert",
            data: {
              screen: 'movie_details',
              movieId: movieId.toString(),
            },
          };

          await storeNotification(userDoc.id, notification);
          await sendPushNotification(userDoc.id, notification);
        }
      }
    });
  } catch (error) {
    console.error("Error sending release notifications:", error);
  }

  return null;
});

export const sendCollaborationInvite = onDocumentUpdated("users/{userId}", async (event) => {
  const userId = event.params.userId;

  const beforeData = event.data.before.data();
  const afterData = event.data.after.data();

  const oldPendingInvites = beforeData?.pendingInvites || {};
  const newPendingInvites = afterData?.pendingInvites || {};

  let watchlistOwner = null;
  let watchlistId = null;

  for (const [owner, newWatchlists] of Object.entries(newPendingInvites)) {
    const oldWatchlists = oldPendingInvites[owner] || [];

    const addedWatchlists = newWatchlists.filter(id => !oldWatchlists.includes(id));

    if (addedWatchlists.length > 0) {
      watchlistOwner = owner;
      watchlistId = addedWatchlists[0];
      break;
    }
  }

  if (!watchlistOwner || !watchlistId) {
    console.log("No new invitation found");
    return null;
  }

  try {
    const watchlistOwnerDoc = await db.doc(`users/${watchlistOwner}`).get();
    const watchlistOwnerData = watchlistOwnerDoc.data();

    const watchlistDoc = await db.doc(`users/${watchlistOwner}/my_watchlists/${watchlistId}`).get();
    const watchlistData = watchlistDoc.data();

    const notification = {
      message: `${watchlistOwnerData.username} wants to add you as collaborator in their watchlist '${watchlistData.name}'!`,
      type: "new_invitation",
      watchlistOwner: watchlistOwner,
      watchlistId: watchlistId,
      title: "New invitation!",
    };
    
    await storeNotification(userId, notification);
    await sendPushNotification(userId, notification);
  } catch (error) {
    console.error("Error sending collaboration invite notification:", error);
  }

  return null;
});