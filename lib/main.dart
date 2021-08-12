// import
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage_app/screens/home_screen.dart';
import 'package:flutter/material.dart';

/*  ************************************************************************  */

// master function
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(AppName());
}

/*  ************************************************************************  */

// class principal
class AppName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}