import 'package:chatting_app/screens/auth/login_screen.dart';
import 'package:chatting_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:typethis/typethis.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomePage()));
      } else {
        Navigator.pushReplacement(
            // context, MaterialPageRoute(builder: (_) => LoginScreen()));
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: [
        Positioned(
            top: mq.height * .15,
            width: mq.width * .5,
            right: mq.width * .25,
            child: Image.asset('assets/images/chat.png')),
        Positioned(
          bottom: mq.height * .15,
          width: mq.width * .9,
          left: mq.width * .05,
          height: mq.height * .07,
          // child: TypeThis(
          //   string: 'Hello how are you doing?',
          //   speed: 50,
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //     fontSize: 18,
          //     color: Colors.black,
          //   ),
          // ),
          child: const Text(
            'MADE IN INDIA WITH ❤️ ',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0, color: Colors.black87),
          ),
        ),
      ]),
    );
  }
}
