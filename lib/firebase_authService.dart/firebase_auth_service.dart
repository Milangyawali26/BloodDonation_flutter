import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

//this function is to  sign up  
  Future<User?> createUserWithEmailAndPassword(
      String email, String password,) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (fException) {
      print('Firebase Signup Error $fException');
    } catch (e) {
      print('Something went wrong!!');
    }
    return null;
  }

  ///This function is used to login user with email and password
  Future<User?> loginInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Firebase Login Error $e');
    } catch (e) {
      print('Something Went Wrong');
    }
    return null;
  }

  ///This function is used to signout user
  void signOutUser() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    try {
      return _auth.currentUser;
    } catch (e) {
      print('Something Went Wrong');
    }
    return null;
  }
}
