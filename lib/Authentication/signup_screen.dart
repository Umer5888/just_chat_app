import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_validator/form_validator.dart';

import '../Helper/ui_helper.dart';
import '../Models/user_model.dart';
import '../Others/Animation.dart';
import '../Profile Management/setup_profile_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({ Key? key }) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if(email == "" || password == "" || cPassword == "") {
      UIHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields");
    }
    else if(password != cPassword) {
      UIHelper.showAlertDialog(context, "Password Mismatch", "The passwords you entered do not match!");
    }
    else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, "Creating new account..");

    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(ex) {
      Navigator.pop(context);

      UIHelper.showAlertDialog(context, "An error occured", ex.message.toString());
    }

    if(credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
          uid: uid,
          email: email,
          username: '',
          profile: '',
          about: '',
        phonenumber: '',
        isOnline: false,
      );
      await FirebaseFirestore.instance.collection("users").doc(uid).set(newUser.toMap()).then((value) {
        print("New User Created!");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          SlidePageRoute(
              page: SetupProfileScreen(userModel: newUser, firebaseUser: credential!.user!)
          ),
        );
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
          ),
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
                            'Signup',
                            style: TextStyle(
                                fontSize: 45, fontWeight: FontWeight.w600, color: Colors.green, height: 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30,),

                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                        labelText: "Email Address",
                      prefixIcon: Icon(Icons.email)
                    ),
                    validator: ValidationBuilder().email().maxLength(30).build(),

                  ),

                  SizedBox(height: 15,),

                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "Password",
                      prefixIcon: Icon(Icons.password)
                    ),
                    validator: ValidationBuilder().maxLength(14).minLength(6).build(),

                  ),

                  SizedBox(height: 15,),

                  TextFormField(
                    controller: cPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "Confirm Password",
                        prefixIcon: Icon(Icons.password)
                    ),
                    validator: ValidationBuilder().maxLength(14).minLength(6).build(),

                  ),

                  SizedBox(height: 30,),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            checkValues();
                          },
                          child: Text('Signup', style: TextStyle(color: Colors.white)),
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

            Text("Already have an account?", style: TextStyle(
                fontSize: 16
            ),),

            CupertinoButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Log In", style: TextStyle(
                  fontSize: 16
              ),),
            ),

          ],
        ),
      ),
    );
  }
}

