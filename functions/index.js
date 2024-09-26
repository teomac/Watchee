const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// notification for new follower
exports.sendFollowNotification = functions
    .firestore.document("users/{userId}")
    .onUpdate(async (change, context) => {
      const userId = context.params.userId;

      const beforeData = change.before.data();
      const afterData = change.after.data();

      // Retrieve the old and new follower lists
      const oldFollowers = beforeData.followers || [];
      const newFollowers = afterData.followers || [];

      // Find the new followers by comparing lists
      const newFollowerIds = newFollowers
          .filter((id) => !oldFollowers.includes(id));

      // If no new followers, exit early
      if (newFollowerIds.length === 0) {
        return null;
      }

      try {
        // Retrieve user document
        const userDoc = await admin.firestore().doc(`users/${userId}`).get();
        const userData = userDoc.data();
        const userFcmToken = userData.fcmToken;

        // Send notification for each new follower
        for (const followerId of newFollowerIds) {
          const followerDoc = await admin
              .firestore()
              .doc(`users/${followerId}`)
              .get();
          const followerData = followerDoc.data();
          const followerName = followerData.username;

          const message = `${followerName} is now following you!`;

          if (userFcmToken) {
            await admin.messaging().send({
              token: userFcmToken,
              notification: {
                title: "New follower!",
                body: message,
              },
            });
            console.log(`Notification sent for new follower: ${followerName}`);

            // store notification in firestore with notificationId
            const notificationsRef = admin.firestore().collection(`users/${userId}/notifications`);
            const notificationId = notificationsRef.doc().id;
            await notificationsRef.doc(notificationId).set({
              notificationId,
              message,
              timestamp: admin.firestore.FieldValue.serverTimestamp(),
              type: "new_follower",
              followerId,
            });

            // notifications number check
            const snapshot = await notificationsRef.orderBy('timestamp').limit(11).get();

            if (snapshot.size > 10) {
              const oldestDoc = snapshot.docs[0];
              await oldestDoc.ref.delete();
            }

          } else {
            console.log("No FCM token found for user");
          }
        }
      } catch (error) {
        console.error("Error sending notification:", error);
      }

      return null;
    });


// notification for new friend review
exports.sendReviewNotification = functions
    .firestore.document("reviews/{reviewId}")
    .onCreate(async (snapshot, context) => {
      const reviewData = snapshot.data();
      const reviewAuthorId = reviewData.userId;

      try {
        const reviewAuthorDoc = await admin
            .firestore().doc(`users/${reviewAuthorId}`).get();
        const reviewAuthorData = reviewAuthorDoc.data();
        const reviewAuthorName = reviewAuthorData.username;

        const followers = reviewAuthorData.followers || [];

        if (followers.length === 0) {
          return null;
        }

        for (const followerId of followers) {
          const followerDoc = await admin
              .firestore().doc(`users/${followerId}`).get();
          const followerData = followerDoc.data();
          const followerFcmToken = followerData.fcmToken;

          if (followerFcmToken) {
            const message = `${reviewAuthorName} just posted a new review!`;

            await admin.messaging().send({
              token: followerFcmToken,
              notification: {
                title: "New review posted!",
                body: message,
              },
            });
            console.log(
                `Notification sent to follower ${followerData.username}`);

            // store notification in firestore with notificationId
            const notificationsRef = admin.firestore().collection(`users/${followerId}/notifications`);
            const notificationId = notificationsRef.doc().id;
            await notificationsRef.doc(notificationId).set({
              notificationId,
              message,
              timestamp: admin.firestore.FieldValue.serverTimestamp(),
              type: "new_review",
              reviewAuthorId,
              reviewAuthorName,
            });

            // notifications number check
            const snapshot = await notificationsRef.orderBy('timestamp').limit(11).get();

            if (snapshot.size > 10) {
              const oldestDoc = snapshot.docs[0];
              await oldestDoc.ref.delete();
            }

          } else {
            console.log(`No FCM token found for follower ${followerId}`);
          }
        }
      } catch (error) {
        console.error("Error sending review notification: ", error);
      }
      return null;
    });


exports.getSharedWatchlist = functions.https.onRequest(async (request, response) => {
      // Enable CORS
    response.set('Access-Control-Allow-Origin', '*');
    
    if (request.method === 'OPTIONS') {
        // Send response to OPTIONS requests
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
        // Get the watchlist document
        const watchlistDoc = await admin.firestore()
          .collection('users').doc(userId)
          .collection('my_watchlists').doc(watchlistId)
          .get();
    
        if (!watchlistDoc.exists) {
          response.status(404).send('Watchlist not found');
          return;
        }
    
        const watchlistData = watchlistDoc.data();
    
        // Check if the watchlist is private
        if (watchlistData.isPrivate) {
          response.status(403).send('This watchlist is private');
          return;
        }
    
        // Get the user document
        const userDoc = await admin.firestore()
          .collection('users').doc(userId)
          .get();
    
        if (!userDoc.exists) {
          response.status(404).send('User not found');
          return;
        }
    
        const userData = userDoc.data();

        // Get the user document of the person who shared the watchlist
        const sharedByDoc = await admin.firestore()
          .collection('users').doc(invitedBy)
          .get();

        if (!sharedByDoc.exists) {
          response.status(404).send('User not found');
          return;
        }

        const sharedByData = sharedByDoc.data();
    
    
        // Prepare the response data
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
