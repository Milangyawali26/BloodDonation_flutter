
import 'package:blood_app/firebase_authService.dart/Wrapper.dart';
import 'package:blood_app/firebase_options.dart';
import 'package:blood_app/screens/become_donor.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/homepage.dart';
import 'screens/login.dart';
import 'screens/profile.dart';
import 'screens/signup.dart';
import 'screens/splash.dart';



void main() async
 {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
          title: 'flutter App',
    theme: ThemeData(
      colorSchemeSeed: const Color.fromARGB(255, 92, 9, 9),
    ),
    routes: {
      '/': (context) => const Splash(),
      '/wrapper.dart':(context)=>  const Wrapper(),
      '/login': (context) => const Login(),
      '/signup': (context) => const SignUp(),
      '/homepage':(context)=>const HomePage(),
      '/profile':(context)=>const Profile(),
      '/donorRegister':(context)=>const DonorRegister(),
    },
    initialRoute: '/',
    debugShowCheckedModeBanner: false,
     
    );
  }
}