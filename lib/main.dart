
import 'package:blood_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ML_model_services/tf_Lite_services.dart';
import 'firebase_Service.dart/Wrapper.dart';
import 'screens/become_donor.dart';
import 'screens/btn_nav_bar.dart';
import 'screens/donor_profile.dart';
import 'screens/homepage.dart';
import 'screens/login.dart';
import 'screens/myBloodRequest.dart';
import 'screens/profile.dart';
import 'screens/request_for_blood.dart';
import 'screens/signup.dart';
import 'screens/splash.dart';


void main() async {

  // 
  WidgetsFlutterBinding.ensureInitialized();
  final tfliteService = TFLiteService();
  await tfliteService.loadModel();

  //initialize fire base 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // // Initialize Firebase messaging service 
  // FirebaseMsgServices firebaseMsgServices = FirebaseMsgServices();
  // await firebaseMsgServices.initializeMessaging();

  runApp(const MyApp());
}


// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print('Handling background message: ${message.messageId}');
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Blood Donation App',
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 92, 9, 9),
      ),
      routes: {
       '/splash': (context) => const Splash(),
        '/wrapper': (context) => const Wrapper(),
        '/btm_nav_bar': (context) => const BtmNavigationBar(),
        '/login': (context) => const Login(),
        '/signup': (context) => const SignUp(),
        '/homepage': (context) => const HomePage(),
        '/profile': (context) => const Profile(),
        '/donorRegister': (context) => const DonorRegister(),
        '/donorProfile': (context) => const DonorProfile(),
        '/myBloodRequest': (context) => const MyBloodRequest(),
        '/addRequest': (context) => const RequestForBlood(),
      },
      initialRoute: '/splash',
      debugShowCheckedModeBanner: false,
    );
  }
}

