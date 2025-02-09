import 'package:blood_app/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../model/user_model.dart';
import 'locationService.dart';

class FirebaseDatabaseServices {
  var bloodRequestList=[];
  final donorList = [];
  List<DonorModel>? donorListCache;
  final _firestoreDb = FirebaseFirestore.instance;

 


  /// Create a user in Cloud Firestore
  void createUser({required UserModel userModel}) async {
    try {
      final CollectionReference usersCollectionReference =
          _firestoreDb.collection('users');
      await usersCollectionReference.doc(userModel.id).set(userModel.toJson());
      Get.snackbar("   Success"  , "user created ");
      print('User Creation Success');
    } catch (e) {
      Get.snackbar("failed "  , "user not created in database ");
      print(' user creation on database failed . Something went wrong $e');
    }
  }

  /// Create a donor in the database
  void createDonor(
      {required DonorModel donorModel, required BuildContext context}) async {
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
                  Navigator.of(context).pop(
                      //        MaterialPageRoute(builder: (context) => Profile()),
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
      Get.snackbar("failed "  , "donor registration failed. ");
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
          await _firestoreDb
              .collection('donors')
              .where('id', isEqualTo: uid)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Return the first matching document as a DonorModel
        final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            querySnapshot.docs.first;
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


// this is unused function
  Future<List<Map<String, dynamic>>> getDonorsInACollection() async {
    List<Map<String, dynamic>> donorList = []; // Initialize donorList here
    try {
      final CollectionReference donorsCollectionReference =
          _firestoreDb.collection('donors');
      QuerySnapshot querySnapShot = await donorsCollectionReference.get();

      // Use map to convert documents into a list
      donorList = querySnapShot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return donorList;
    } catch (e) {
      print('Something Went Wrong: $e');
      return []; // Return an empty list in case of an error
    }
  }




  // Function to calculate the Haversine distance between two points
  Future<double> calculateHaversineDistance(double donorLatitude,
      double donorLongitude, Position userPosition) async {
    const double earthRadius = 6371; // Radius of the Earth in kilometers
    double distance;
    // Convert degrees to radians
    double lat1Rad = userPosition.latitude * pi / 180;
    double lon1Rad = userPosition.longitude * pi / 180;
    double lat2Rad = donorLatitude * pi / 180;
    double lon2Rad = donorLongitude * pi / 180;

    // Haversine formula
    double dLat = lat2Rad - lat1Rad;
    double dLon = lon2Rad - lon1Rad;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    distance = earthRadius * c; // Distance in kilometers
    return distance;
  }



  // Function to get donors from database and calculate distances
  Future<List<DonorModel>> getDonorsFromDatabase() async {
    if (donorListCache != null) {
      return donorListCache!; // Return cached list if available
    }

    List<DonorModel> donorList = [];
    Position userPosition;
    try {
      // Get user's current location
      userPosition = await LocationService().getCurrentLocation();

      final CollectionReference donorsCollectionReference =
          _firestoreDb.collection('donors');
      // Query to get only available donors
      final QuerySnapshot<Object?> snapShot = await donorsCollectionReference
          .where('isAvailable', isEqualTo: true) // Filter for available donors
          .get();

      if (snapShot.docs.isNotEmpty) {
        donorList = snapShot.docs
            .map((doc) => DonorModel.fromJson(
                doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();
      } else {
        throw Exception('No donors found');
      }

      print("donor list length = ${donorList.length}");
      // Calculate distances for each donor
      for (var donor in donorList) {
        double? donorLatitude = donor.latitude;
        double? donorLongitude = donor.longitude;

        if (donorLatitude != null && donorLongitude != null) {
          // Await the distance calculation and store it in the donor model
          donor.distance = await calculateHaversineDistance(
              donorLatitude, donorLongitude, userPosition);
        } else {
          donor.distance =
              double.infinity; // Set a large value if location is missing
        }
      }

      // Sort the donorList by distance in ascending order
      donorList.sort((a, b) => a.distance!.compareTo(b.distance!));

      // Cache the donor list for future use
      donorListCache = donorList;
      print("the length of cached donor list ${donorListCache?.length}");

    } catch (e) {
      print('Something went wrong: $e');
    }
    return donorList;
  }

// Example of the LocationService class to get the user's current location





//update donors using uid
  Future<DonorModel?> updateDonorsUsingId(
      {required BuildContext context,
      required String uid,
      required DonorModel donorModel}) async {
    try {
      final CollectionReference usersCollectionReference =
          _firestoreDb.collection('donors');
      final documentSnapshot =
          await usersCollectionReference.where('id', isEqualTo: uid).get();
      if (documentSnapshot.docs.isNotEmpty) {
        final documentId = documentSnapshot.docs.first.id;
        await usersCollectionReference
            .doc(documentId)
            .update(donorModel.toJson())
            .then((_) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Donor  updated "),
              content: const Text(" Donor profile updated Successfully"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                        // MaterialPageRoute(builder: (context) => const DonorProfile()),
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
        });
      } else {
        print("donor not found here ");
        return null;
      }
    } catch (e) {
      print('Something went wrong $e');
    }
    return null;
  }


//update donors avalibilty usind uid 
  Future<void> updateDonorAvailability({required String uid, required bool isAvailable}) async {
    try {
      await _firestoreDb.collection('donors').doc(uid).update({
        'isAvailable': isAvailable,
      });
    } catch (e) {
      print('Error updating availability: $e'); // Handle error appropriately
    }
  }


// function  add Blood request in database
  void addRequest(
      {required RequestModel requestModel,
      required BuildContext context}) async {
    // Add request to bloodRequest collection
  DocumentReference docRef = await _firestoreDb.collection('bloodRequest').add(requestModel.toJson());

  // Get the auto-generated document ID
  String requestId = docRef.id;

  // Update the document by adding requestId field
  await docRef.update({
    'requestId': requestId,
  });
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("request added sussfully"),
              actions: [
                TextButton(
                  onPressed: () {
                     Navigator.of(context).pushReplacementNamed('/wrapper');
                  },
                  child: const Text('okay'),
                ),
              ],
            ));
  }


// get bloodrequest form userid of current user
Future<List<RequestModel>?> getBloodRequestFromId({
  required String uid,
}) async {
  try {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestoreDb
        .collection('bloodRequest')
        .where('userId', isEqualTo: uid)
        .get();

    // Create a list of RequestModel from the documents fetched
    if (querySnapshot.docs.isNotEmpty) {
      List<RequestModel> requestList = querySnapshot.docs.map((doc) {
        // Access document data as Map<String, dynamic>
        return RequestModel.fromJson(doc.data()); // No change needed here
      }).toList();
      return requestList; // Return the list of RequestModel
    } else {
      print("Current user's blood request not found");
      return []; // Return an empty list instead of null
    }
  } catch (e) {
    print("Something went wrong while getting current user blood request: $e");
    return []; // Return an empty list on error
  }
}


// Get all blood requests
Future<List<RequestModel>> getAllBloodRequest() async {
  List<RequestModel> bloodRequestList = [];

  try {
    final CollectionReference bloodRequestsCollection = _firestoreDb.collection('bloodRequest');
    final QuerySnapshot<Map<String, dynamic>> snapShot = await bloodRequestsCollection.get() as QuerySnapshot<Map<String, dynamic>>; // Cast the result
    
    if (snapShot.docs.isNotEmpty) {
      bloodRequestList = snapShot.docs.map((doc) {
        // Pass the document data (as Map<String, dynamic>) directly
        return RequestModel.fromJson(doc.data()); 
      }).toList();
    } else {
      throw Exception("No blood requests found");
    }

    return bloodRequestList;
  } catch (e) {
    print('Something went wrong here: $e');
    return []; // Return an empty list in case of an error
  }
}


// update blood request by id  
Future<RequestModel?>updateBloodRequestUsingId(
      {required BuildContext context,
      required String uid,
      required String requestId,
      required RequestModel requestModel}) async{

         try {
      final CollectionReference usersCollectionReference =
          _firestoreDb.collection('bloodRequest');
      final documentSnapshot =
          await usersCollectionReference.where('requestId', isEqualTo: requestId).get();
      if (documentSnapshot.docs.isNotEmpty) {


        final documentId = documentSnapshot.docs.first.id;

        


  // Update the document by adding requestId field

        await usersCollectionReference
            .doc(documentId)
            .update(requestModel.toJson());

         await usersCollectionReference
            .doc(documentId)
            .update({'requestId': documentId,});            
            {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("updated "),
              content: const Text("  blood request  updated Successfully"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                   Navigator.of(context).pushReplacementNamed('/wrapper');
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
      } else {
        print("request not found here ");
       // return null;
      }
    } catch (e) {
      print('Something went wrong $e');
    }
    return null;
      }
    


  // Method to fetch blood request data based on uid and requestId
  Future<RequestModel?> fetchBloodRequest({required String uid, required String requestId}) async {
    try {
      // Accessing the collection where blood requests are stored
      DocumentSnapshot<Map<String, dynamic>> requestSnapshot = await _firestoreDb
          .collection('bloodRequest') // Sub-collection for blood requests
          .doc(requestId)      // Referencing the specific request document
          .get();

      if (requestSnapshot.exists) {
        // If document exists, convert the fetched data to RequestModel
        return RequestModel.fromJson(requestSnapshot.data()!);
      } else {
        return null; // Return null if no data is found
      }
    } catch (e) {
      print("Error fetching blood request: $e");
      return null;
    }
  }


  // method to delete bloodrequest by request id and uid
  static Future<void> deleteBloodRequest(String requestId,String uid)async{
    try{
      //Refernces of firestore collection
      CollectionReference bloodRequest=FirebaseFirestore.instance.collection('bloodRequest');
      //
      //Query the collection to find the specific request by request id and uid
      QuerySnapshot snapshot=await bloodRequest.where('requestId',isEqualTo: requestId).where('userId',isEqualTo: uid).get();
      
      //if the document exists, delete it 
      if(snapshot.docs.isNotEmpty){
        await snapshot.docs.first.reference.delete();
        print(" blood request deleted successfully");
      }
      else{
        print("no matching blood request found.");
      }
    }catch(e){
      print('error deleting blood request:$e');
    }
  }


}
