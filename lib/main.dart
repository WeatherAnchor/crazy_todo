import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app_home_page.dart';
import 'app_login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      ;
      log('User is currently signed out!');
    } else {
      log('User is signed in!');
    }
  });

  User? user = FirebaseAuth.instance.currentUser;
  runApp(MyApp(
    user: user,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, this.user}) : super(key: key);
  final User? user;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: MyHomePage(),
      home: (user != null)
          ? HomePage(
              user: user,
            )
          : LoginPage(),
    );
  }
}
