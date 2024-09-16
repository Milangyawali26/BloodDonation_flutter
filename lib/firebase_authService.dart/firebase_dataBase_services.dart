import 'package:blood_app/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:blood_app/model/user_model.dart';

class FirebaseDatabaseServices {
  final donorList=[];
  final _firestoreDb = FirebaseFirestore.instance;

  /// Create a user in Cloud Firestore
  void createUser({required UserModel userModel}) async {
    try {
      final CollectionReference usersCollectionReference = _firestoreDb.collection('users');
      await usersCollectionReference.doc(userModel.id).set(userModel.toJson());
      print('User Creation Success');
    } catch (e) {
      print('Something went wrong $e');
    }
  }

  /// Create a donor in the database
  void createDonor({required DonorModel donorModel, required BuildContext context}) async {
    try {
      QuerySnapshot querySnapshot = await _firestoreDb
          .collection('donors')
          .where('id', isEqualTo: donorModel.id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Donor Already Exists"),
            content: const Text("You have already registered as a donor."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) =>  Profile()),
                  );
                },
                child: Container(
                  color: Colors.green,
                  padding: const EdgeInsets.all(14),
                  child: const Text("Okay"),
                ),
              ),
            ],
          ),
        );
        print('Donor with ID: ${donorModel.id} already exists.');
      } else {
        await _firestoreDb.collection('donors').add(donorModel.toJson());
        print('Donor added successfully.');
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Donor Registered Successfully"),
            content: const Text("You are now registered as a donor."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const Profile()),
                  );
                },
                child: Container(
                  color: Colors.green,
                  padding: const EdgeInsets.all(14),
                  child: const Text("Okay"),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Something went wrong $e');
    }
  }

  /// Get user details from uid Firestore
  Future<UserModel?> getUserDetailsFromUid({required String uid}) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _firestoreDb.collection('users').doc(uid).get();

      if (documentSnapshot.exists) {
        print('User document found');
        return UserModel.fromJson(documentSnapshot);
      } else {
        print('User document not found');
        return null;
      }
    } catch (e) {
      print('Something went wrong: $e');
      return null;
    }
  }

  /// Get donor details from id Firestore
  Future<DonorModel?> getDonorDetailsFromId({required String uid}) async {
    try {
      // Use where clause to match the donor with the given ID
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _firestoreDb.collection('donors').where('id', isEqualTo: uid).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Return the first matching document as a DonorModel
        final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = querySnapshot.docs.first;
        print('Donor document found');
        return DonorModel.fromJson(documentSnapshot);
      } else {
        print('Donor document not found');
        return null;
      }
    } catch (e) {
      print('Something went wrong: $e');
      return null;
    }
  }

  Future getUsersInACollection() async {
    try {
      final CollectionReference _usersCollectionReference =
          await _firestoreDb.collection('users');
      await _usersCollectionReference.get().then((querySnapShot) {
        for (var doc in querySnapShot.docs) {
          donorList.add(doc.data());
        }
      });
      return donorList;
    } catch (e) {
      print('Something Went Wrong $e');
    }
  }


  //get donors from database
 Future<List<DonorModel>> getDonorsFromDatabase() async {
  List<DonorModel> donorList = [];
  try {
    final CollectionReference donorsCollectionReference = _firestoreDb.collection('donors');
    final QuerySnapshot<Object?> snapShot = await donorsCollectionReference.get();

    if (snapShot.docs.isNotEmpty) {
      donorList = snapShot.docs
          .map((doc) => DonorModel.fromJson(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } else {
      throw Exception('No donors found');
    }
  } catch (e) {
    print('Something went wrong $e');
  }
  return donorList;
}


}
