const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Notification Cloud Function - Triggered when cover status changes
exports.sendStatusChangeNotification = functions.firestore
    .document('coverSystem/status')
    .onUpdate(async (change, context) => {
      try {
        const before = change.before.data();
        const after = change.after.data();
        
        // Check if the status actually changed
        if (before.isExtended === after.isExtended) {
          console.log('Status unchanged, skipping notification');
          return null;
        }
        
        const isExtended = after.isExtended;
        const timestamp = new Date().toLocaleString();
        
        console.log(`Status changed to: ${isExtended ? 'Extended' : 'Retracted'}`);
        
        // Prepare notification payload
        const title = '🏠 Clothesline Update';
        const body = isExtended 
          ? '☂️ Cover has been extended - Your clothes are protected!'
          : '☀️ Cover has been retracted - Perfect drying conditions!';
        
        // Get all user tokens
        const usersSnapshot = await admin.firestore()
          .collection('users')
          .where('fcmToken', '!=', null)
          .get();
        
        const tokens = [];
        usersSnapshot.forEach(doc => {
          const userData = doc.data();
          if (userData.fcmToken) {
            tokens.push(userData.fcmToken);
          }
        });
        
        console.log(`Found ${tokens.length} tokens to send notifications to`);
        
        if (tokens.length === 0) {
          console.log('No tokens found, skipping notifications');
          return null;
        }
        
        // Send notifications to all users
        const payload = {
          notification: {
            title: title,
            body: body,
            icon: 'ic_launcher',
            sound: 'default',
          },
          data: {
            status: isExtended.toString(),
            timestamp: timestamp,
            source: 'status_change',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
        };
        
        // Send to all tokens
        const response = await admin.messaging().sendToDevice(tokens, payload);
        
        console.log(`Notification sent successfully to ${response.successCount} devices`);
        
        if (response.failureCount > 0) {
          console.log(`Failed to send to ${response.failureCount} devices`);
          
          // Clean up invalid tokens
          const invalidTokens = [];
          response.results.forEach((result, index) => {
            if (result.error && (
              result.error.code === 'messaging/invalid-registration-token' ||
              result.error.code === 'messaging/registration-token-not-registered'
            )) {
              invalidTokens.push(tokens[index]);
            }
          });
          
          // Remove invalid tokens from database
          if (invalidTokens.length > 0) {
            console.log(`Removing ${invalidTokens.length} invalid tokens`);
            const batch = admin.firestore().batch();
            
            const usersWithInvalidTokens = await admin.firestore()
              .collection('users')
              .where('fcmToken', 'in', invalidTokens)
              .get();
            
            usersWithInvalidTokens.forEach(doc => {
              batch.update(doc.ref, { fcmToken: admin.firestore.FieldValue.delete() });
            });
            
            await batch.commit();
          }
        }
        
        return response;
      } catch (error) {
        console.error('Error sending notification:', error);
        throw error;
      }
    });

// Test function to manually trigger notifications
exports.testNotification = functions.https.onRequest(async (req, res) => {
  try {
    const message = req.query.message || 'Test notification from Cloud Function';
    const title = req.query.title || '🧪 Test Notification';
    
    // Get all user tokens
    const usersSnapshot = await admin.firestore()
      .collection('users')
      .where('fcmToken', '!=', null)
      .get();
    
    const tokens = [];
    usersSnapshot.forEach(doc => {
      const userData = doc.data();
      if (userData.fcmToken) {
        tokens.push(userData.fcmToken);
      }
    });
    
    if (tokens.length === 0) {
      res.json({ success: false, message: 'No tokens found' });
      return;
    }
    
    const payload = {
      notification: {
        title: title,
        body: message,
        icon: 'ic_launcher',
        sound: 'default',
      },
      data: {
        source: 'test',
        timestamp: new Date().toISOString(),
      },
    };
    
    const response = await admin.messaging().sendToDevice(tokens, payload);
    
    res.json({
      success: true,
      message: `Test notification sent to ${response.successCount} devices`,
      details: {
        successCount: response.successCount,
        failureCount: response.failureCount,
        tokens: tokens.length
      }
    });
  } catch (error) {
    console.error('Error in test notification:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});