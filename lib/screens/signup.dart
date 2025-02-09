import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../firebase_authService.dart/otppage.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  bool passwordVisible = false;
  final _fullNameController = TextEditingController();
  final _signupPhoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailRegexPattern =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@gmail.com";
  final _emailAddressController = TextEditingController();

  Future<void> sendcode() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+977${_signupPhoneNumberController.text}',
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-sign in not used here
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage;
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'The provided phone number is not valid.';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many attempts. Please try again later.';
          } else {
            errorMessage = 'An error occurred: ${e.message}';
          }
          Get.snackbar('Verification Error', errorMessage,
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        },
        codeSent: (String verificationId, int? token) {
          setState(() {
            verificationId = verificationId;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpPage(
                verificationId: verificationId,
                fullName: _fullNameController.text,
                email: _emailAddressController.text,
                signUpPhoneNumber: _signupPhoneNumberController.text,
                password: _passwordController.text,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Code retrieval timed out');
        },
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error Occurred", e.message ?? 'data base issue  error',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error Occurred', e.toString(),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: Colors.red,
          title: const Text("SignUp"),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  // Full name input
                  TextFormField(
                    controller: _fullNameController,
                    keyboardType: TextInputType.name,
                    maxLength: 30,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^[a-zA-Z\s]*$'),
                      ), // Allows only letters and spaces
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter full name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (fullNameValue) {
                      if (fullNameValue == null ||
                          fullNameValue.trim().isEmpty) {
                        return 'Please Enter Full Name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Email input
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
                  const SizedBox(height: 10),

                  // Phone number input
                  TextFormField(
                    maxLength: 10,
                    controller: _signupPhoneNumberController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Mobile Number for Signup',
                      prefixIcon: Icon(Icons.phone_android),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      } else if (value.length != 10) {
                        return 'Mobile number must be 10 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Password input
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    maxLength: 20,
                    obscureText: !passwordVisible,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                      if (passwordValue == null ||
                          passwordValue.trim().isEmpty) {
                        return 'Please Enter password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Login redirection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/login');
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  // Signup button
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: SizedBox(
                      height: 50,
                      width: 300,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange),
                        onPressed: () async {
                          print('Sign up button clicked');
                          if (_formKey.currentState != null &&
                              _formKey.currentState!.validate()) {
                            await sendcode();
                          }
                        },
                        child: const Text(
                          "Signup",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
