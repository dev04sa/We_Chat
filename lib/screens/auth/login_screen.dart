import 'dart:developer';
import 'dart:io';

import 'package:chatting_app/apis/api.dart';
import 'package:chatting_app/helper/dialogs.dart';
import 'package:chatting_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGooglebtnClick() async {
    // for show progress bar
    Dialogs.showProgressbar(context);
   await signInWithGoogle().then((user) async {
      // for hiding progress bar
      Navigator.pop(context);
      if (user != null) {
        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomePage()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomePage()));
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    try {
      // await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      log('signInWithGoogle : ${e.toString()}');
      Dialogs.showSnackbar(context, 'Somthing Went wrong (Check Internet)');
      return null;
    }
  }

  // sign out function
  _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Welcome to We Chat'),
      ),
      body: Stack(children: [
        AnimatedPositioned(
            top: mq.height * .15,
            width: mq.width * .5,
            right: _isAnimate ? mq.width * .25 : -mq.width * .5,
            duration: Duration(milliseconds: 1000),
            child: Image.asset('assets/images/chat.png')),
        Positioned(
            bottom: mq.height * .15,
            width: mq.width * .9,
            left: mq.width * .05,
            height: mq.height * .07,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 81, 213, 85),
                    shape: StadiumBorder()),
                onPressed: () {
                  // Navigator.pushReplacement(
                  //     context, MaterialPageRoute(builder: (_) => HomePage()));
                  _handleGooglebtnClick();
                },
                icon: Image.asset(
                  width: 40,
                  'assets/images/google.png',
                ),
                label: Text(
                  'Sign in With Google',
                  style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ))),
      ]),
    );
  }
}
