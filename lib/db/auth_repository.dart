

import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // returns snapshot when there is a change in collection in DB
  Stream<User?> userAuthChange (){
    return _auth.authStateChanges();
  }

  User? getCurrentUser () {
    return _auth.currentUser;
  }



  Future<void> deleteUser() async {
    try {
      return await this._auth.currentUser!.delete();
    } catch (e) {
      print('Failed to be deleted');
      throw e;
    }
  }

  // sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Failed logging out - contact with the App developers');
      throw e;
    }
  }


  Future<User> registerWithEmailAndPassword(String email, String password) async
  {
    try {

      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      User? user = result.user;
      if (user == null) {
        throw 'Failed creating a new user in FB';
      }

      return user;

    } on FirebaseAuthException catch (e) {
      switch(e.code) {
        case 'email-already-in-use': throw 'The account already exists for that email';

        case 'invalid-email': throw 'the email address is not valid';

        case 'weak-password': throw 'password is not strong enough';

      // for operator
        case 'operation-not-allowed': {
          print('email/password accounts are not enabled');
          throw 'Your account is not enabled - contact with the App developers';
        }

        default: throw 'Invalid values inserted';
      }
    } catch (e) {
      print('Failed to register - contact with the App developers');
      throw e;
    }
  }

  Future<User> signInWithEmailAndPassword(String email, String password) async
  {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      /* if signing in succeeded - creating new AppUser, because he is currently logged in
      else, returning an error */
      return user != null ? user : throw 'Failed signing in to FB';

    } on FirebaseAuthException catch (e) {
      switch(e.code) {
        case 'invalid-email': throw 'Invalid email address';

        case 'user-disabled': throw 'Your account has been disabled - contact with the App developers';

        case 'user-not-found': throw 'There is no user corresponding to the given email';

        case 'wrong-password': throw 'The password is invalid for the given email';

        default: throw 'Invalid values inserted';
      }
    } catch (e) {
      print('Failed signing in - contact with the App developers');
      throw e;
    }
  }


// // checking if the user is still logged in
// Future<User?> attemptAutoLogin() async {
//   try {
//     User? curUser = _auth.currentUser;
//     if(curUser == null) return null;
//     // returning the uid
//     return curUser;
//
//   } catch (e) {
//     throw e;
//   }
// }


}