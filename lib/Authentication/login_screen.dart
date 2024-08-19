import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:just_chat/Authentication/forget_password.dart';
import 'package:just_chat/Authentication/signup_screen.dart';
import 'package:just_chat/Others/Animation.dart';

import '../Helper/ui_helper.dart';
import '../Models/user_model.dart';
import '../Chat Screens/chat_list.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the fields");
    } else {
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? credential;

    UIHelper.showLoadingDialog(context, "Logging In..");

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      // Close the loading dialog
      Navigator.pop(context);

      // Show Alert Dialog
      UIHelper.showAlertDialog(
          context, "An error occurred", ex.message.toString());
      return;
    }

    if (credential != null) {
      String uid = credential.user!.uid;

      // Update online status
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'isOnline': true});

      DocumentSnapshot userData =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel =
      UserModel.fromMap(userData.data() as Map<String, dynamic>);

      // Go to ChatListScreen
      print("Log In Successful!");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        SlidePageRoute(
          page: ChatListScreen(
              userModel: userModel, firebaseUser: credential.user!)
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Just',
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w600, color: Colors.black54, height: 1),
                          ),
                          Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 45, fontWeight: FontWeight.w600, color: Colors.green, height: 1),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 30),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                        labelText: "Email Address",
                        prefixIcon: Icon(Icons.email)
                    ),
                    validator: ValidationBuilder()
                        .email()
                        .maxLength(30)
                        .build(),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.password),
                    ),
                    validator: ValidationBuilder()
                        .maxLength(14)
                        .minLength(6)
                        .build(),
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            checkValues();
                          },
                          child: Text('Login', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  TextButton(
                    onPressed: (){
                      Navigator.push(context, 
                          SlidePageRoute(page: ForgotPasswordScreen()));
                    },
                    child: Text("Forgot Password?", style: TextStyle(color: Colors.green)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account?",
                style: TextStyle(fontSize: 16)),
            CupertinoButton(
              onPressed: () {
                Navigator.push(
                  context,
                  SlidePageRoute(
                    page: SignupScreen()
                  ),
                );
              },
              child: Text("Sign Up", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
