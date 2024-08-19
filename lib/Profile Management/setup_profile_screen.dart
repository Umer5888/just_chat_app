import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:image_picker/image_picker.dart';

import '../Helper/ui_helper.dart';
import '../Models/user_model.dart';
import '../Chat Screens/chat_list.dart';
import '../Others/Animation.dart';

class SetupProfileScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SetupProfileScreen({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  _SetupProfileScreenState createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {

  File? imageFile;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values
    fullNameController.text = widget.userModel.username!;
    aboutController.text = widget.userModel.about!;
    phoneNumberController.text = widget.userModel.phonenumber!;
  }

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    } else {
      print("No image selected");
    }
  }

  void showPhotoOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Upload Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
                leading: Icon(Icons.photo_album),
                title: Text("Select from Gallery"),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                },
                leading: Icon(Icons.camera_alt),
                title: Text("Take a photo"),
              ),
            ],
          ),
        );
      },
    );
  }

  void checkValues() {
    String fullname = fullNameController.text.trim();
    String about = aboutController.text.trim();
    String phoneNumber = phoneNumberController.text.trim();

    if(fullname.isEmpty || imageFile == null || about.isEmpty || phoneNumber.isEmpty) {
      print("Please fill all the fields");
      UIHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields and upload a profile picture");
    }
    else {
      log("Uploading data..");
      uploadData();
    }
  }

  void uploadData() async {
    UIHelper.showLoadingDialog(context, "Uploading image..");

    UploadTask uploadTask = FirebaseStorage.instance.ref("profile").child(widget.userModel.uid.toString()).putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? username = fullNameController.text.trim();
    String? about = aboutController.text.trim();
    String? phonenumber = phoneNumberController.text.trim();

    widget.userModel.username = username;
    widget.userModel.profile = imageUrl;
    widget.userModel.about = about;
    widget.userModel.phonenumber = phonenumber;

    await FirebaseFirestore.instance.collection("users").doc(widget.userModel.uid).set(widget.userModel.toMap()).then((value) {
      log("Data uploaded!");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        SlidePageRoute(page: ChatListScreen(userModel: widget.userModel, firebaseUser: widget.firebaseUser)
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Setup Profile", style: TextStyle(color: Colors.white),),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              SizedBox(height: 20),
              CupertinoButton(
                onPressed: () {
                  showPhotoOptions();
                },
                padding: EdgeInsets.all(0),
                child: CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 70,
                  backgroundImage: (imageFile != null) ? FileImage(imageFile!) : null,
                  child: (imageFile == null) ? Icon(Icons.person, color: Colors.white, size: 50,) : null,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person, color: Colors.green,)
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: aboutController,
                decoration: InputDecoration(
                  labelText: "About",
                    prefixIcon: Icon(Icons.notes, color: Colors.green,)
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                    prefixIcon: Icon(Icons.phone, color: Colors.green,)
                ),
                validator: ValidationBuilder().minLength(11).build(),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                       checkValues();
                      },
                      child: Text('Save & Continue', style: TextStyle(color: Colors.white)),
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
    );
  }
}


