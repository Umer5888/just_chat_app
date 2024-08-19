// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:just_chat/Helper/utils.dart';
// import 'package:just_chat/edit_profile_screen.dart';
// import 'package:just_chat/welcome_screen.dart';
// import 'package:uuid/uuid.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   File? image;
//   final picker = ImagePicker();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final Uuid uuid = Uuid();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   bool _isUploading = false;
//
//   Future<void> getGalleryImage() async {
//     final pickedFile = await picker.pickImage(
//         source: ImageSource.gallery, imageQuality: 80);
//     if (pickedFile != null) {
//       setState(() {
//         image = File(pickedFile.path);
//       });
//       await uploadImageToFirebase();
//     } else {
//       Utils().errorMessage('Image not picked!');
//     }
//   }
//
//   Future<void> getCameraImage() async {
//     final pickedFile = await picker.pickImage(
//       source: ImageSource.camera,
//       imageQuality: 80,
//     );
//     if (pickedFile != null) {
//       setState(() {
//         image = File(pickedFile.path);
//       });
//       await uploadImageToFirebase();
//     } else {
//       Utils().errorMessage('Image not captured!');
//     }
//   }
//
//   String getCurrentUserId() {
//     final User? user = _auth.currentUser;
//     if (user != null) {
//       return user.uid;
//     } else {
//       throw Exception("No user is currently signed in.");
//     }
//   }
//
//   Future<void> uploadImageToFirebase() async {
//     if (image != null) {
//       setState(() {
//         _isUploading = true;
//       });
//       try {
//         // Upload the file to Firebase Storage
//         UploadTask uploadTask = _storage
//             .ref()
//             .child('Images/${uuid.v1()}')
//             .putFile(image!);
//
//         // Get the download URL
//         TaskSnapshot taskSnapshot = await uploadTask;
//         String downloadUrl = await taskSnapshot.ref.getDownloadURL();
//
//         // Get the current user ID
//         String userId = getCurrentUserId();
//
//         // Update the user's profile picture in Firestore
//         await _firestore.collection('Users').doc(userId).update({
//           'profilepic': downloadUrl,
//         });
//
//         Utils().successMessage('Profile picture updated successfully!');
//       } catch (e) {
//         Utils().errorMessage('Failed to upload image: $e');
//       } finally {
//         setState(() {
//           _isUploading = false;
//         });
//       }
//     }
//   }
//
//   void showPhotoOptions() {
//     showDialog(context: context, builder: (context) {
//       return AlertDialog(
//         title: Text("Upload Profile Picture"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               onTap: () async {
//                 Navigator.pop(context);
//                 await getGalleryImage();
//               },
//               leading: Icon(Icons.photo_album),
//               title: Text("Select from Gallery"),
//             ),
//             ListTile(
//               onTap: () async {
//                 Navigator.pop(context);
//                 await getCameraImage();
//               },
//               leading: Icon(Icons.camera_alt),
//               title: Text("Take a photo"),
//             ),
//           ],
//         ),
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     String userId = getCurrentUserId();
//
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.green,
//         centerTitle: true,
//         title: Text(
//           'Your Profile',
//           style: TextStyle(
//             color: Colors.white,
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 10),
//             child: IconButton(
//               onPressed: () {
//                 Navigator.of(context).push(
//                   SliderPageRoute(
//                     builder: (context) => StreamBuilder<DocumentSnapshot>(
//                       stream: _firestore.collection('Users').doc(userId).snapshots(),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.waiting) {
//                           return Center(child: CircularProgressIndicator());
//                         }
//                         if (!snapshot.hasData || snapshot.data == null) {
//                           return Center(child: Text("No user data found."));
//                         }
//
//                         var userData = snapshot.data!.data() as Map<String, dynamic>;
//                         return EditProfileScreen(userData: userData);
//                       },
//                     ),
//                   ),
//                 );
//               },
//               icon: Icon(Icons.edit, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: _firestore.collection('Users').doc(userId).snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data == null) {
//             return Center(child: Text("No user data found."));
//           }
//
//           var userData = snapshot.data!.data() as Map<String, dynamic>;
//
//           return Column(
//             children: [
//               SizedBox(height: 20),
//               Center(
//                 child: Stack(
//                   alignment: Alignment.bottomCenter,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       child: Container(
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(100),
//                             border: Border.all(width: 1, color: Colors.grey)),
//                         child: Container(
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(100),
//                               border: Border.all(width: 0.5, color: Colors.grey)),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(100),
//                             child: _isUploading
//                                 ? SizedBox(
//                                   width: 120,
//                                   height: 120,
//                                   child: Center(child: CircularProgressIndicator()),
//                             )
//                                 : Image.network(
//                                   userData['profilepic'] ??
//                                       'assets/images/profile.jpeg',
//                                   fit: BoxFit.cover,
//                                   width: 120,
//                                   height: 120,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Image.asset(
//                                   'assets/images/profile.jpeg',
//                                   fit: BoxFit.cover,
//                                   width: 120,
//                                   height: 120,
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     InkWell(
//                       borderRadius: BorderRadius.circular(100),
//                       onTap: () {
//                         showPhotoOptions();
//                       },
//                       child: Container(
//                         width: 30,
//                         height: 30,
//                         decoration: BoxDecoration(
//                             color: Colors.green,
//                             borderRadius: BorderRadius.circular(100)),
//                         child: Icon(Icons.add, color: Colors.white, size: 20),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 30),
//               Divider(),
//               ListTile(
//                 leading: Icon(Icons.person, color: Colors.green,),
//                 title: Text('Name'),
//                 trailing: Text(
//                   userData['username'] ?? 'Name not available',
//                   style: TextStyle(fontSize: 12),
//                 ),
//               ),
//               Divider(),
//               ListTile(
//                 leading: Icon(Icons.mail, color: Colors.green,),
//                 title: Text('Email'),
//                 trailing: Text(
//                   userData['email'] ?? 'Update Your Email',
//                   style: TextStyle(fontSize: 12),
//                 ),
//               ),
//               Divider(),
//               ListTile(
//                 leading: Icon(Icons.notes, color: Colors.green,),
//                 title: Text('About'),
//                 trailing: Text(
//                   userData['about'] ?? 'About not available',
//                   style: TextStyle(fontSize: 12),
//                 ),
//               ),
//               Divider(),
//               ListTile(
//                 leading: Icon(Icons.phone, color: Colors.green,),
//                 title: Text('Phone Number', style: TextStyle(fontSize: 14),),
//                 trailing: Text(
//                   userData['phone'] ?? '+92',
//                   style: TextStyle(fontSize: 12),
//                 ),
//               ),
//               Divider(),
//               SizedBox(height: 30,),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(5),
//                           )
//                         ),
//                         onPressed: () async {
//                           showDialog(
//                               context: context,
//                               builder: (context) {
//                                 return AlertDialog(
//                                   title: Text('Log out',
//                                       style: TextStyle(fontSize: 18, color: Colors.red)),
//                                   content: Row(
//                                     children: [
//                                       Text('Are you sure you want to Log out?'),
//                                     ],
//                                   ),
//                                   actions: [
//                                     ElevatedButton(
//                                         style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.green,
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius: BorderRadius.circular(5),
//                                             )
//                                         ),
//                                         onPressed: () async {
//                                           FirebaseAuth.instance.signOut();
//                                           Navigator.of(context).pushAndRemoveUntil(
//                                               SliderPageRoute(builder: (context) => WelcomeScreen())
//                                               , (route) => false);
//                                         },
//                                         child: Text('Yes', style: TextStyle(color: Colors.white),)
//                                     ),
//                                     ElevatedButton(
//                                         style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.red,
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius: BorderRadius.circular(5),
//                                             )
//                                         ),
//                                         onPressed: (){
//                                           Navigator.of(context).pop();
//                                         },
//                                         child: Text(
//                                           textAlign: TextAlign.center,
//                                           'No ',
//                                         style: TextStyle(color: Colors.white),)
//                                     )
//                                   ],
//                                 );
//                               }
//                           );
//                         },
//                         child: Text('Log out', style: TextStyle(color: Colors.white),),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
