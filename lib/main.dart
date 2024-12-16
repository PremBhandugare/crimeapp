// lib/main.dart
import 'package:crimeapp/noti.dart';
import 'package:crimeapp/screens/SplashScr.dart';
import 'package:crimeapp/screens/home.dart';
import 'package:crimeapp/screens/loginscr.dart';
import 'package:crimeapp/screens/tab.dart';
import 'package:crimeapp/screens/timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Noti.initialise(flutterLocalNotificationsPlugin);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Safety App',
      theme: ThemeData(
         colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red),
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.openSansTextTheme(),    
      ),
      home: Tabs(flnp: flutterLocalNotificationsPlugin,),
    );
  }
}
