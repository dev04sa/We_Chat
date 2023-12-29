import 'dart:developer';

import 'package:chatting_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';
import 'firebase_options.dart';

late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDefault();
  // ignore: deprecated_member_use
  mq = WidgetsBinding.instance.window.physicalSize;
  runApp(const MyApp());

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'We Chat',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.amber,
            centerTitle: true,
            elevation: 1.0,
            titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 22.0,
                fontWeight: FontWeight.normal),
          )),
      home: const SplashScreen(),
    );
  }
}

Future<void> initializeDefault() async {
  FirebaseApp app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showinng Message Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
    visibility: NotificationVisibility.VISIBILITY_PUBLIC,
    allowBubbles: true,
    enableVibration: true,
    enableSound: true,
    showBadge: true,
  );
  log(result);
}
