import 'package:blood_app/firebase_authService.dart/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  bool passwordVisible = false;

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
                              ? Icons.visibility_off
                              : Icons.visibility,
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
      
                  // Container(
                  //   alignment: Alignment.topLeft,
                  //   child: const Text(
                  //     "Forget Password ? " ,
                  //     style: TextStyle(
                  //         color: const Color.fromARGB(255, 184, 59, 206),
                  //         fontStyle: FontStyle.italic),
                  //   ),
                  // ),
                  SizedBox(
                    height: 10,
                  ),
      
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Don't have Account?",
                          style: TextStyle(
                              color: const Color.fromARGB(255, 184, 59, 206),
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
                  SizedBox(height: 10,),
      
                  // login button
                  SizedBox(
                    height: 50,
                    width: 300,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange),
                        onPressed: () async {
                          print("login btn clicked");
                          if (_formKey.currentState != null) {
                            if (_formKey.currentState!.validate()) {
                              final firebaseAuthService = FirebaseAuthService();
                              final email = _emailAddressController.text;
                              final password = _passwordController.text;
                              final User? user = await firebaseAuthService
                                  .loginInWithEmailAndPassword(email, password);
                              if (user != null) {
                                final SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString('id', user.uid);
                                print('Login Success');
                                Navigator.of(context)
                                    .pushReplacementNamed('/wrapper');
                              } else {
                                print('Login Failed');
                              }
                            }
                          }
                        },
                        child: const Text(
                          "login",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        )),
                  ),
                  // const Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 50, vertical: 50),
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //         child: Divider(
                  //             color: Colors.black,
                  //             height: 5,
                  //             indent: 16,
                  //             thickness: 2,
                  //             endIndent: 16),
                  //       ),
                  //       Text("Or"),
                  //       Expanded(
                  //         child: Divider(
                  //             color: Colors.black,
                  //             height: 5,
                  //             indent: 16,
                  //             thickness: 2,
                  //             endIndent: 16),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 50,
                  //   width: 300,
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //         backgroundColor: Color.fromARGB(255, 178, 213, 231)),
                  //     onPressed: () {},
                  //     child: Text("Sign in with Google",
                  //         style: TextStyle(
                  //           color: Colors.red,
                  //           fontWeight: FontWeight.bold,
                  //         )),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
