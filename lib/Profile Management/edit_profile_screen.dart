import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../Helper/utils.dart';
import '../Models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel userModel;

  const EditProfileScreen({super.key, required this.userModel});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> key = GlobalKey();
  bool isLoading = false;
  bool isImageUploading = false;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userModel.username ?? '';
    _phoneController.text = widget.userModel.phonenumber ?? '';
    _aboutController.text = widget.userModel.about ?? '';
    _profileImageUrl = widget.userModel.profile;
  }

  Future<void> uploadImage(File imageFile) async {
    setState(() {
      isImageUploading = true;
    });
    try {
      String userId = _auth.currentUser!.uid;
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      setState(() {
        _profileImageUrl = downloadUrl;
      });

      // Update Firestore with the new profile image URL
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profile': _profileImageUrl,
      });

    } catch (e) {
      Utils().errorMessage('Failed to upload profile picture: $e');
    } finally {
      setState(() {
        isImageUploading = false;
      });
    }
  }

  Future<void> getGalleryImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      uploadImage(File(pickedFile.path));
    }
  }

  Future<void> getCameraImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      uploadImage(File(pickedFile.path));
    }
  }

  void showPhotoOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Upload Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  getGalleryImage();
                },
                leading: const Icon(Icons.photo_album),
                title: const Text("Select from Gallery"),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  getCameraImage();
                },
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a photo"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> updateProfile() async {
    setState(() {
      isLoading = true;
    });
    try {
      String userId = _auth.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'username': _nameController.text,
        'phonenumber': _phoneController.text,
        'about': _aboutController.text,
        'profile': _profileImageUrl,
      });
      Utils().successMessage('Profile updated successfully!');
      Navigator.pop(context);
    } catch (e) {
      Utils().errorMessage('Failed to update profile: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId = _auth.currentUser!.uid;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var userDoc = snapshot.data!;
          _nameController.text = userDoc['username'] ?? '';
          _phoneController.text = userDoc['phonenumber'] ?? '';
          _aboutController.text = userDoc['about'] ?? '';
          _profileImageUrl = userDoc['profile'];

          return Column(
            children: [
              const SizedBox(height: 30),
              GestureDetector(
                onTap: showPhotoOptions,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 60,
                      backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
                      child: _profileImageUrl == null
                          ? const Icon(Icons.camera_alt, size: 50, color: Colors.white)
                          : null,
                    ),
                    if (isImageUploading)
                      const CircularProgressIndicator(color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: key,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                            labelText: 'Username'
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Phone Number'),
                        keyboardType: TextInputType.phone,
                        validator: ValidationBuilder().phone().maxLength(11).minLength(11).build(),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _aboutController,
                        decoration: const InputDecoration(labelText: 'About'),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: (){
                                if (key.currentState?.validate() ?? false){
                                  updateProfile();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5))),
                              child: isLoading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white),
                              )
                                  : const Text('Update Profile',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
