import 'package:blood_app/firebase_authService.dart/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _emailRegexPattern =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
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
                    obscureText: passwordVisible, // Variable name corrected
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
                            passwordVisible =
                                !passwordVisible; // Update the state
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
      
              
                 const  SizedBox(
                    height: 10,
                  ),
      
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Don't have Account?",
                          style: TextStyle(
                              color:  Color.fromARGB(255, 184, 59, 206),
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
                  const SizedBox(height: 10,),
      
              // Login button
SizedBox(
  height: 50,
  width: 300,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
    ),
    onPressed: () async {
      print("Login button clicked");
      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
        final firebaseAuthService = FirebaseAuthService();
        final email = _emailAddressController.text;
        final password = _passwordController.text;

        try {
          // Attempt to log in the user
          final User? user = await firebaseAuthService
              .loginInWithEmailAndPassword(email, password);

          if (user != null) {
            // Save user ID to shared preferences
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('id', user.uid);

            print('Login Success');
            Navigator.of(context).pushReplacementNamed('/wrapper');
          } else {
            Get.snackbar("Error", 'please enter valid email and password', backgroundColor: Colors.redAccent, colorText: Colors.white);
            print('Login failed: User not found');
          }
        } on FirebaseAuthException catch (e) {
          // Handle specific Firebase authentication errors
          String errorMessage;
          if (e.code == 'user-not-found') {
            errorMessage = 'No user found with this email.';
          } else if (e.code == 'wrong-password') {
            errorMessage = 'Incorrect password. Please try again.';
          } else if (e.code == 'network-request-failed') {
            errorMessage = 'Network error. Please check your connection.';
          } else {
            errorMessage = 'An unexpected error occurred: ${e.message}';
          }
          print('Login failed: $errorMessage');
          Get.snackbar("Login Error", errorMessage, backgroundColor: Colors.white, colorText: Colors.redAccent);
        } catch (e) {
          // Handle any other errors
          print('An unexpected error occurred: $e');
          Get.snackbar("Error", 'An unexpected error occurred. Please try again.', backgroundColor: Colors.white, colorText: Colors.redAccent);
        }
      }
    },
    child: const Text(
      "Login",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
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
}
