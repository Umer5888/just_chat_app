import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_chat/Helper/firebase_helper.dart';
import 'package:just_chat/Others/welcome_screen.dart';
import 'package:just_chat/Chat%20Screens/chat_list.dart';
import '../Models/user_model.dart';
import 'animation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 4), () async {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Logged In
        UserModel? thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);
        if (thisUserModel != null) {
          Navigator.pushReplacement(context, SlidePageRoute(page: ChatListScreen(userModel: thisUserModel, firebaseUser: currentUser)));
        } else {
          Navigator.pushReplacement(context, SlidePageRoute(page: const WelcomeScreen()));
        }
      } else {
        // Not logged in
        Navigator.pushReplacement(context, SlidePageRoute(page: const WelcomeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.green,
        child: const Center(
          child: Text(
            'Just Chat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
