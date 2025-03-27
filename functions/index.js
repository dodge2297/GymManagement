// functions/index.js
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getAuth } = require('firebase-admin/auth');

initializeApp();

exports.deleteUser = onCall(
  { region: 'us-central1' },
  async (request) => {
    console.log('Function called with data:', request.data);
    console.log('Auth context:', request.auth);

    // Check if the caller is authenticated
    if (!request.auth) {
      console.log('No authenticated user');
      throw new HttpsError('unauthenticated', 'Not authenticated');
    }

    const callerUid = request.auth.uid;
    console.log('Caller UID:', callerUid);

    // Check if the caller is an admin
    try {
      const userDoc = await getFirestore().collection('users').doc(callerUid).get();
      if (!userDoc.exists) {
        console.log('Caller document does not exist in Firestore');
        throw new HttpsError('not-found', 'Caller not found in Firestore');
      }
      if (!userDoc.data().isAdmin) {
        console.log('Caller is not an admin');
        throw new HttpsError('permission-denied', 'Admin privileges required');
      }
    } catch (error) {
      console.log('Error checking caller admin status:', error.message);
      throw new HttpsError('internal', `Error checking admin status: ${error.message}`);
    }

    // Validate the userId parameter
    const { userId } = request.data;
    if (!userId) {
      console.log('User ID not provided');
      throw new HttpsError('invalid-argument', 'User ID required');
    }

    // Delete the user
    try {
      console.log('Deleting user document from Firestore:', userId);
      await getFirestore().collection('users').doc(userId).delete();
      console.log('Deleting user from Authentication:', userId);
      await getAuth().deleteUser(userId);
      console.log('User deleted successfully:', userId);
      return { message: `User ${userId} deleted successfully from Firestore and Authentication` };
    } catch (error) {
      console.log('Error deleting user:', error.message);
      throw new HttpsError('internal', `Error deleting user: ${error.message}`);
    }
  }
);