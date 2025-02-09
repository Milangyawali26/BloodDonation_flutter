import 'package:blood_app/firebase_Service.dart/firebase_dataBase_services.dart';
import 'package:blood_app/screens/donor_profile.dart';
import 'package:blood_app/screens/myBloodRequest.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:blood_app/model/user_model.dart';
import '../firebase_Service.dart/firebase_auth_service.dart';

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
      final userDetails =
          await _databaseServices.getUserDetailsFromUid(uid: currentUser!.uid);
      setState(() {
        userModel = userDetails;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () async {
                            final firebaseAuthService = FirebaseAuthService();
                            firebaseAuthService.signOutUser();
                            Navigator.of(dialogContext).pop();
                            Navigator.of(context)
                                .pushReplacementNamed('/login');
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: userModel == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Stack(
                  children: [           Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: ProfileImage()),
                        const SizedBox(height: 15),
                        ListTile(
                          title: const Text('Full Name'),
                          subtitle: Text(userModel!.fullName ?? 'N/A'),
                        ),
                        ListTile(
                          title: const Text('Phone Number'),
                          subtitle: Text(userModel!.signUpPhoneNumber ?? 'N/A'),
                        ),

                        const SizedBox(height: 10),
                        // Become a Donor button

                        // Menu items
                        MenuWidgets(
                          title: 'Settings',
                          onPressed: () {
                            print('Settings Clicked');
                          },
                          icon: Icons.settings,
                        ),
                        const SizedBox(height: 20),
                        MenuWidgets(
                          title: 'Notifications',
                          onPressed: () {
                            print('Notifications Clicked');
                          },
                          icon: Icons.notifications,
                        ),
                        const SizedBox(height: 20),
                        MenuWidgets(
                          title: 'About App',
                          icon: Icons.info,
                        ),
                      ],
                    ),

                    Positioned(
                      right: 30,
                      top: 130,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DonorProfile()),
                          );
                        },
                        child: const Text(
                          "Donor Profile",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    //my blood request
                    Positioned(
                      right: 30,
                      top: 180,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text(
                          'My Blood Request',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyBloodRequest()),
                          );
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

// Circular profile image
class ProfileImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 100,
      width: 100,
      child: CircleAvatar(
        backgroundImage: AssetImage('assets/profileimage.jpeg'),
      ),
    );
  }
}

// Reusable menu widget
class MenuWidgets extends StatelessWidget {
  final String title;
  final void Function()? onPressed;
  final IconData icon;

  const MenuWidgets({
    required this.title,
    this.onPressed,
    this.icon = Icons.arrow_forward_ios,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // Changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Icon(icon, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
