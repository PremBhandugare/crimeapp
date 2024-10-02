// lib/main.dart
import 'package:crimeapp/noti.dart';
import 'package:crimeapp/screens/SplashScr.dart';
import 'package:crimeapp/screens/home.dart';
import 'package:crimeapp/screens/loginscr.dart';
import 'package:crimeapp/screens/tab.dart';
import 'package:crimeapp/screens/timer.dart';
import 'package:crimeapp/translations/codegen_loader.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'firebase_options.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Noti.initialise(flutterLocalNotificationsPlugin);
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(
    EasyLocalization(
      path: 'assets/translations',
      supportedLocales: [
        Locale('en'),
        Locale('hi')
      ],
      fallbackLocale: Locale('en'),
      assetLoader: CodegenLoader(),
      child: MyApp()
      ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Safety App',
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      theme: ThemeData(
         colorScheme: ColorScheme.fromSeed(
            seedColor:Colors.red),
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.openSansTextTheme(),    
      ),
      home: Tabs(flnp: flutterLocalNotificationsPlugin,),
      // routes: {
      //   '/': (context) => Home(crimeData: [],),
      //   '/map': (context) => SplashScr(crimeData: [],),
      //   '/updates': (context) => (),
      //   '/signin': (context) =>const  LoginScr(),
      // },
    );
  }
}

