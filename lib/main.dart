import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDeqSMUO05LUjr32ANw6gwm47Q7iJ0BqsQ",
      appId: "1:585643387380:android:b0b22ec7d749a0c4ba31a1",
      messagingSenderId: '585643387380',
      projectId: "kiddiewheels-2669b",
    ),
  );
  runApp(MyApp());
}
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KiddieWheels',
      theme: ThemeData(
        primaryColorLight: Colors.white,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      // Start with the Login Page   
      home: LoginPage(),
    );
  }
}

