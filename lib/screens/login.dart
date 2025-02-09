import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_authService.dart/Wrapper.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _emailRegexPattern =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@gmail.com";
  final _emailAddressController = TextEditingController();

  bool passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: Colors.red,
          title: const Text("Login"),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailAddressController,
                    maxLength: 30,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email address',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (emailValue) {
                      if (emailValue == null || emailValue.trim().isEmpty) {
                        return 'Please enter your email address';
                      }
                      final regex = RegExp(_emailRegexPattern);
                      if (!regex.hasMatch(emailValue)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    maxLength: 20,
                    obscureText: passwordVisible,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                      ),
                      hintText: 'Password',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                    validator: (passwordValue) {
                      if (passwordValue == null || passwordValue.trim().isEmpty) {
                        return 'Please Enter password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Login button
                  SizedBox(
                    height: 50,
                    width: 300,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: _loginWithEmailPassword,
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18,color:Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                   Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Don't have Account?",
                          style: TextStyle(
                              color: Color.fromARGB(255, 212, 49, 49),
                              
                              fontStyle: FontStyle.italic),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/signup');
                            },
                            child: const Text(
                              "SignUp",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loginWithEmailPassword() async {
    final userEmail = _emailAddressController.text.trim();
    final userPassword = _passwordController.text.trim();

    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Try to sign in the user with email and password
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: userEmail,
          password: userPassword,
        );

        // Get FCM token after successful login
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          // Save FCM token to Firestore
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).update({
            'fcmToken': fcmToken,
          });
        }

        // Store userId in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userId', userCredential.user?.uid ?? '');

        // Navigate to the next screen
        Get.offAll(const Wrapper());
          Get.snackbar(
          'Login Success',
          'u are succssfully login',
          backgroundColor: Colors.white,
          colorText: Colors.green,
          );

      } on FirebaseAuthException catch (e) {
        // Handle Firebase Authentication errors
        String errorMessage = 'An error occurred. Please try again.';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password. Please try again.';
        }
        Get.snackbar(
          'Login Failed',
          errorMessage,
          backgroundColor: Colors.white,
          colorText: Colors.redAccent,
        );
      } on FirebaseException catch (e) {
        // Handle Firestore or Firebase Messaging errors
        Get.snackbar(
          'Error',
          'allow notification permission on your device !!',
          backgroundColor: Colors.white,
          colorText: Colors.redAccent,
        );
        print("Firestore error: ${e.message}");
      } catch (e) {
        // Catch all other exceptions
        Get.snackbar(
          'Login Failed',
          'An unexpected error occurred. Please try again later.',
          backgroundColor: Colors.white,
          colorText: Colors.redAccent,
        );
        print("Unexpected error: $e");
      }
    }
  }
}
