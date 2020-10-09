import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_pk/caches/user.dart';
import 'package:flutter_pk/global.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginApi {
  Future<String> initiateLogin() async {
    GoogleSignInAuthentication googleAuth = await _handleGoogleSignIn();

    final fb_auth.AuthCredential credential =
        fb_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final authResult = await auth.signInWithCredential(credential);
    final fb_auth.User user = authResult.user;

//    FirebaseUser user = await auth.signInWithGoogle(
//      accessToken: googleAuth.accessToken,
//      idToken: googleAuth.idToken,
//    );

    await _setUserToFireStore(user);

    return user.uid;
  }

  Future _setUserToFireStore(fb_auth.User user) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection(FireStoreKeys.userCollection);

    await reference.doc(user.uid).get().then((snap) async {
      if (!snap.exists) {
        User _user = User(
            name: user.displayName,
            mobileNumber: user.phoneNumber,
            id: user.uid,
            photoUrl: user.photoURL,
            email: user.email);

        await reference
            .doc(user.uid)
            .set(_user.toJson(), SetOptions(merge: true));
      }
    });
  }

  Future<GoogleSignInAuthentication> _handleGoogleSignIn() async {
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    return googleAuth;
  }

  initialize() {
    /*
    FirebaseFirestore.instance.settings = Settings(
      timestampsInSnapshotsEnabled: true,
    );
    */

    // FirebaseFirestore.instance.settings = FirebaseFirestoreSettings();
  }
}
