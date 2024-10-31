
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
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  final _emailAddressController = TextEditingController();

  sendcode() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+977${_signupPhoneNumberController.text}',
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {
            Get.snackbar('Error occured', e.code);
          },
          codeSent: (String verificationId, int? token) {
            setState(() {
              verificationId=verificationId;
            });
            Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpPage(
              verificationId: verificationId,
              fullName: _fullNameController.text,
              email:_emailAddressController.text,
              signUpPhoneNumber: _signupPhoneNumberController.text,
              password: _passwordController.text,
              
            ),
          ),
        );
          },
          codeAutoRetrievalTimeout: (verificationId) {});
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error Occured", e.code);
    } catch (e) {
      Get.snackbar('Error Occured', e.toString());
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
            
                  TextFormField(
                    controller: _fullNameController,
                    keyboardType: TextInputType.name,
                    maxLength: 30,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter full name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (fullNameValue) {
                      if (fullNameValue == null || fullNameValue.trim().isEmpty) {
                        return 'Please Enter Full Name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  
                  const SizedBox(width: 10),
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
                    SizedBox(height: 10,),
                  TextFormField(
                    maxLength: 10,
                    controller: _signupPhoneNumberController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Mobile Number for Signup',
                      prefixIcon: Icon(Icons.phone_android),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      } else if (value.length != 10) {
                        return 'Mobile number must be 10 digits';
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
                          passwordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible; // Update the state
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('already have an account'),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/login');
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: SizedBox(
                      height: 50,
                      width: 300,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange),
                          onPressed: () async {
                                      print('sign up button clicked');
                            if(_formKey.currentState!=null){
                              if(_formKey.currentState!.validate()){
                            sendcode();
                              }
                            }
                          },
                          child: const Text(
                            "Signup",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.white),
                          )),
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
