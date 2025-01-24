

import "dart:async";
import "package:blood_app/firebase_authService.dart/Wrapper.dart";
import "package:flutter/material.dart";


class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
@override

 void initState() {
    super.initState();
    // Add a delay using Timer for 3 seconds
    Timer(const Duration(seconds: 3), () {
      // After the delay, navigate to the main page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Wrapper(),
        ),
      );
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body:Center(
          child: CircularProgressIndicator(),
        )
      ),
    );
  }
}