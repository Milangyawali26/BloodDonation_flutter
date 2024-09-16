import 'package:blood_app/firebase_authService.dart/firebase_dataBase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:blood_app/model/user_model.dart';

import '../firebase_authService.dart/firebase_auth_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseDatabaseServices _databaseServices = FirebaseDatabaseServices();
  User? currentUser = FirebaseAuth.instance.currentUser;
  UserModel? userModel;
  

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    if (currentUser != null) {
      final userDetails = await _databaseServices.getUserDetailsFromUid(uid: currentUser!.uid);
      setState(() {
        userModel = userDetails;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Profile'),
        centerTitle: true,
         actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        icon: const Icon(Icons.warning),
                        title: const Text('Signout User'),
                        content: const Text('Are you sure you want to Signout?'),
                        actions: [
                          InkWell(
                            child: const Text('Ok'),
                            onTap: () async {
                              final firebaseAuthService = FirebaseAuthService();
                              firebaseAuthService.signOutUser();
                            

                              Navigator.of(dialogContext).pop();
                              Navigator.of(context)
                                  .pushReplacementNamed('/login');
                            },
                          ),
                          InkWell(
                            child: const Text('Cancel'),
                            onTap: () {
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ],
      ),
      body: SingleChildScrollView(
        child: userModel == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    ListTile(
                      title: const Text('Full Name'),
                      subtitle: Text(userModel!.fullName ?? 'N/A'),
                    ),
                    ListTile(
                      title: const Text('Phone Number'),
                      subtitle: Text(userModel!.signUpPhoneNumber ?? 'N/A'),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text(
                          "Become a Donor",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/donorRegister');
                        },
                      ),
                    ),
                     Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text(
                          "donor profile",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/donorProfile');
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
