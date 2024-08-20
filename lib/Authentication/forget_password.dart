import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Helper/ui_helper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController = TextEditingController();

  void resetPassword() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      UIHelper.showAlertDialog(context, "Error", "Please enter your email address.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, "Success", "Password reset email sent.");
    } on FirebaseAuthException catch (e) {
      UIHelper.showAlertDialog(context, "Error", e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('Forgot Password', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reset',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w600, color: Colors.black54, height: 1),
                      ),
                      Text(
                        'Password',
                        style: TextStyle(
                            fontSize: 45, fontWeight: FontWeight.w600, color: Colors.green, height: 1),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text('Send Reset Link', style: TextStyle(color: Colors.white),)
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
