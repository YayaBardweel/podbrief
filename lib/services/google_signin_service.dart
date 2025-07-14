import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleSignInService {
  static final _google = GoogleSignIn();
  static final _auth   = FirebaseAuth.instance;
  static final _fire   = FirebaseFirestore.instance;

  /// Returns the signed-in Firebase [User], or throws.
  static Future<User?> signInWithGoogle() async {
    // 1️⃣ Trigger the Google auth flow
    final googleUser = await _google.signIn();
    if (googleUser == null) {
      // User aborted the sign-in
      return null;
    }

    // 2️⃣ Obtain the auth details
    final googleAuth = await googleUser.authentication;

    // 3️⃣ Create a new credential
    final cred = GoogleAuthProvider.credential(
      accessToken : googleAuth.accessToken,
      idToken     : googleAuth.idToken,
    );

    // 4️⃣ Sign in to Firebase with the Google user credentials
    final userCred = await _auth.signInWithCredential(cred);
    final user     = userCred.user;

    // 5️⃣ (Optional) Save to Firestore if new
    final doc = _fire.collection('users').doc(user!.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'username' : user.displayName,
        'email'    : user.email,
        'photoURL' : user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return user;
  }
}
