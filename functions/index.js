const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

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
          } else {
            console.log("No FCM token found for user");
          }
        }
      } catch (error) {
        console.error("Error sending notification:", error);
      }

      return null;
    });
