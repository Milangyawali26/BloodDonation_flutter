import 'package:blood_app/firebase_authService.dart/Wrapper.dart';
import 'package:blood_app/firebase_authService.dart/firebase_auth_service.dart';
import 'package:blood_app/firebase_authService.dart/firebase_dataBase_services.dart';
import 'package:blood_app/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OtpPage extends StatefulWidget {
  final String verificationId;
  final String fullName;
  final String email;
  final String signUpPhoneNumber;
  final String password;

  const OtpPage({
    super.key,
    required this.verificationId,
    required this.fullName,
    required this.email,
    required this.signUpPhoneNumber,
    required this.password,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  var code = '';

  Future<void> signIn() async {
    try {
      // Check if OTP code is complete before attempting to sign in
      if (code.isEmpty || code.length < 6) {
        Get.snackbar(
          'Invalid OTP',
          'Please enter a valid 6-digit OTP code.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      // Attempt to sign in with the OTP code
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: code,
      );

      final firebaseAuthService = FirebaseAuthService();
      User? user = await firebaseAuthService.createUserWithEmailAndPassword(
        widget.email,
        widget.password,
      );

      if (user != null) {
        // Get FCM token after successful login/signup
      // String? fcmToken = await FirebaseMessaging.instance.getToken();

        // Create a new user model with the provided details
        final userModel = UserModel(
          id: user.uid,
          fullName: widget.fullName,
          signUpPhoneNumber: widget.signUpPhoneNumber,
          email: widget.email,
        );

        // Store user data in Firestore
        FirebaseDatabaseServices().createUser(userModel: userModel);

        // Store the FCM token in Firestore
        // if (fcmToken != null) {
        //   await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        //     'fcmToken': fcmToken, // Save FCM token to Firestore
        //   });
        // }

        // Navigate to the home page or dashboard after successful signup
        Get.offAll(const Wrapper());
      } else {
        Get.snackbar(
          'Signup Error',
          'Could not create user. Please try again.',
          backgroundColor: Colors.white,
          colorText: Colors.redAccent,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'The OTP code is incorrect. Please try again.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled. Please contact support.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'This operation is not allowed. Please contact support.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection and try again.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      Get.snackbar(
        'Error Occurred',
        errorMessage,
        backgroundColor: Colors.white,
        colorText: Colors.redAccent,
      );
    } catch (e) {
      Get.snackbar(
        'Error Occurred',
        e.toString(),
        backgroundColor: Colors.white,
        colorText: Colors.redAccent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Image.asset(
                "assets/otpImage.png",
                height: 300,
                width: 300,
              ),
              const SizedBox(height: 10),
              const Text(
                "OTP Verification",
                style: TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                child: Text(
                  "Enter the OTP sent to your number",
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 50),
              textcode(),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  signIn();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80),
                  child: Text(
                    'Verify and proceed',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textcode() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Pinput(
          length: 6,
          onChanged: (value) {
            setState(() {
              code = value;
            });
          },
        ),
      ),
    );
  }
}
