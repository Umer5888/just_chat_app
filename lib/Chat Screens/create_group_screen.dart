// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import 'Models/chat_room_model.dart';
// import 'Models/user_model.dart';
// import 'main.dart';
//
// class CreateGroupScreen extends StatefulWidget {
//   final UserModel userModel;
//   final User firebaseUser;
//
//   const CreateGroupScreen({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);
//
//   @override
//   _CreateGroupScreenState createState() => _CreateGroupScreenState();
// }
//
// class _CreateGroupScreenState extends State<CreateGroupScreen> {
//   TextEditingController groupNameController = TextEditingController();
//   List<UserModel> selectedUsers = [];
//
//   Future<void> createGroupChat() async {
//     if (groupNameController.text.isEmpty || selectedUsers.isEmpty) return;
//
//     Map<String, dynamic> participants = {};
//     for (var user in selectedUsers) {
//       participants[user.uid!] = true;
//     }
//     participants[widget.userModel.uid!] = true;
//
//     ChatRoomModel newChatroom = ChatRoomModel(
//       chatroomId: uuid.v1(),
//       lastMessage: "",
//       participants: participants,
//       isGroup: true,
//       groupName: groupNameController.text,
//     );
//
//     await FirebaseFirestore.instance
//         .collection("chatrooms")
//         .doc(newChatroom.chatroomId)
//         .set(newChatroom.toMap());
//
//     Navigator.pop(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Create Group"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.check),
//             onPressed: createGroupChat,
//           )
//         ],
//       ),
//       body: Column(
//         children: [
//           TextField(
//             controller: groupNameController,
//             decoration: InputDecoration(
//               labelText: "Group Name",
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder(
//               stream: FirebaseFirestore.instance.collection("users").snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.active) {
//                   if (snapshot.hasData) {
//                     QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
//                     return ListView.builder(
//                       itemCount: dataSnapshot.docs.length,
//                       itemBuilder: (context, index) {
//                         UserModel user = UserModel.fromMap(dataSnapshot.docs[index].data() as Map<String, dynamic>);
//                         return CheckboxListTile(
//                           title: Text(user.username!),
//                           value: selectedUsers.contains(user),
//                           onChanged: (bool? selected) {
//                             setState(() {
//                               if (selected!) {
//                                 selectedUsers.add(user);
//                               } else {
//                                 selectedUsers.remove(user);
//                               }
//                             });
//                           },
//                         );
//                       },
//                     );
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text("Error loading users"));
//                   } else {
//                     return Center(child: Text("No users found"));
//                   }
//                 } else {
//                   return Center(child: CircularProgressIndicator());
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
