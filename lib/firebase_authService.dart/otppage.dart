import 'package:blood_app/firebase_authService.dart/Wrapper.dart';
import 'package:blood_app/firebase_authService.dart/firebase_auth_service.dart';
import 'package:blood_app/firebase_authService.dart/firebase_dataBase_services.dart';
import 'package:blood_app/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:pinput/pinput.dart';

class OtpPage extends StatefulWidget {
  final String verificationId;
  final String fullName;
  final String email;
  final String signUpPhoneNumber;
  final String password;
  

  const OtpPage(
      {super.key,
      required this.verificationId,
      required this.fullName,
      required this.email,
      required this.signUpPhoneNumber,
      required this.password});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  var code = '';
  signIn() async {
    try {
      PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: code,
      );

      final firebaseAuthService = FirebaseAuthService();
      User? user = await firebaseAuthService.createUserWithEmailAndPassword(
        widget.email,
        widget.password,
      );

      if (user != null) {

        final userModel =UserModel(
          id:user.uid,
          fullName: widget.fullName,
          signUpPhoneNumber: widget.signUpPhoneNumber,
          email: widget.email,

        );
        FirebaseDatabaseServices().createUser(userModel: userModel);
        
        // Navigate to the home page or dashboard after successful signup
        Get.offAll(const Wrapper());
      } else {
        Get.snackbar('Signup Error', 'Could not create user');
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error occured', e.code);
    } catch (e) {
      Get.snackbar('Error Occured', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "otpImage.png",
              height: 300,
              width: 300,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "otp varification",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              child: Text("enter otp sent to your number",
                  textAlign: TextAlign.center),
            ),
            const SizedBox(
              height: 50,
            ),
              textcode(),
            const SizedBox(
              height: 50,
            ),
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
                        fontWeight: FontWeight.bold),
                  ),
                  
                )),
          ],
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
