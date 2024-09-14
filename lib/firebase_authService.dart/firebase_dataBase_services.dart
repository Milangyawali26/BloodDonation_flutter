

import 'package:blood_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDatabaseServices{
  final usersList=[];
  final _firestoreDb=FirebaseFirestore.instance;



  ///This function is used to create user in cloud firestore
  void createUser({required UserModel userModel}) async {
    try {
      final CollectionReference _usersCollectionReference =
          await _firestoreDb.collection('users');
      await _usersCollectionReference.add(userModel.toJson()).whenComplete(() {
        print('User Creation Success');
      });
    } catch (e) {
      print('Something went wrong $e');
    }
  }
}
