import 'package:blood_app/model/user_model.dart';
import 'package:blood_app/screens/btn_nav_bar.dart';
import 'package:blood_app/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_database_services.dart'; // Import the service where you defined getDonorsFromDatabase

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {

            
            // User is logged in, get the donors from the database
            _getDonors(); // Call the function to get donors
            return const BtmNavigationBar(); // Display the bottom navigation bar
          } else {
            return const Login(); // Display the login page
          }
        },
      ),
    );
  }

  Future<void> _getDonors() async {
    try {
      List<DonorModel> donors = await FirebaseDatabaseServices().getDonorsFromDatabase();
      // You can now use the list of donors in the application
      // Example: Navigate to another page with the donors list or update the UI accordingly
      print("Donors fetched: ${donors.length}");
    } catch (e) {
      print("Error fetching donors: $e");
    }
  }
}
