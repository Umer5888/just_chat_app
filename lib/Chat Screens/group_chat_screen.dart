// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// import 'Models/chat_room_model.dart';
// import 'Models/message_model.dart';
// import 'Models/user_model.dart';
// import 'main.dart';
//
// class GroupChatScreen extends StatefulWidget {
//   final ChatRoomModel chatroom;
//   final UserModel userModel;
//   final User firebaseUser;
//
//   const GroupChatScreen({
//     Key? key,
//     required this.chatroom,
//     required this.userModel,
//     required this.firebaseUser,
//   }) : super(key: key);
//
//   @override
//   _GroupChatScreenState createState() => _GroupChatScreenState();
// }
//
// class _GroupChatScreenState extends State<GroupChatScreen> {
//   TextEditingController messageController = TextEditingController();
//
//   void sendMessage() async {
//     String msg = messageController.text.trim();
//     messageController.clear();
//
//     if (msg != "") {
//       // Send Message
//       MessageModel newMessage = MessageModel(
//         messageId: uuid.v1(),
//         sender: widget.userModel.uid,
//         createdon: Timestamp.now(),
//         text: msg,
//         seen: false,
//       );
//
//       FirebaseFirestore.instance
//           .collection("chatrooms")
//           .doc(widget.chatroom.chatroomId)
//           .collection("messages")
//           .doc(newMessage.messageId)
//           .set(newMessage.toMap());
//
//       widget.chatroom.lastMessage = msg;
//       FirebaseFirestore.instance
//           .collection("chatrooms")
//           .doc(widget.chatroom.chatroomId)
//           .set(widget.chatroom.toMap());
//
//       log("Message Sent!");
//     }
//   }
//
//   String formatTimestamp(Timestamp timestamp) {
//     DateTime dateTime = timestamp.toDate();
//     return DateFormat('h:mm a').format(dateTime);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.green, Colors.teal],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         leading: InkWell(
//           onTap: () {
//             Navigator.of(context).pop();
//           },
//           child: Icon(Icons.arrow_back, color: Colors.white),
//         ),
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: Colors.grey[300],
//               backgroundImage: widget.chatroom.groupIcon != null
//                   ? NetworkImage(widget.chatroom.groupIcon!)
//                   : AssetImage('assets/default_group_icon.png') as ImageProvider,
//               radius: 20,
//             ),
//             SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.chatroom.groupName ?? "Group Chat",
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     "${widget.chatroom.participants?.length ?? 0} participants",
//                     style: TextStyle(color: Colors.white, fontSize: 12),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: SafeArea(
//         child: Container(
//           child: Column(
//             children: [
//               // This is where the chats will go
//               Expanded(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 10),
//                   child: StreamBuilder(
//                     stream: FirebaseFirestore.instance
//                         .collection("chatrooms")
//                         .doc(widget.chatroom.chatroomId)
//                         .collection("messages")
//                         .orderBy("createdon", descending: true)
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.active) {
//                         if (snapshot.hasData) {
//                           QuerySnapshot dataSnapshot =
//                           snapshot.data as QuerySnapshot;
//
//                           return ListView.builder(
//                             reverse: true,
//                             itemCount: dataSnapshot.docs.length,
//                             itemBuilder: (context, index) {
//                               MessageModel currentMessage = MessageModel.fromMap(
//                                   dataSnapshot.docs[index].data()
//                                   as Map<String, dynamic>);
//
//                               bool isSentByUser =
//                                   currentMessage.sender == widget.userModel.uid;
//                               return Align(
//                                 alignment: isSentByUser
//                                     ? Alignment.centerRight
//                                     : Alignment.centerLeft,
//                                 child: Container(
//                                   margin: EdgeInsets.symmetric(vertical: 5),
//                                   padding: EdgeInsets.symmetric(
//                                       vertical: 12, horizontal: 16),
//                                   decoration: BoxDecoration(
//                                     color: isSentByUser
//                                         ? Colors.green
//                                         : Colors.blueGrey,
//                                     borderRadius: BorderRadius.only(
//                                       topLeft: Radius.circular(12),
//                                       topRight: Radius.circular(12),
//                                       bottomLeft: Radius.circular(
//                                           isSentByUser ? 12 : 0),
//                                       bottomRight: Radius.circular(
//                                           isSentByUser ? 0 : 12),
//                                     ),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.2),
//                                         spreadRadius: 1,
//                                         blurRadius: 5,
//                                         offset: Offset(0, 3),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       StreamBuilder<DocumentSnapshot>(
//                                         stream: FirebaseFirestore.instance
//                                             .collection("users")
//                                             .doc(currentMessage.sender)
//                                             .snapshots(),
//                                         builder: (context, snapshot) {
//                                           if (snapshot.hasData &&
//                                               snapshot.data!.exists) {
//                                             UserModel senderUser =
//                                             UserModel.fromMap(snapshot.data!
//                                                 .data()
//                                             as Map<String, dynamic>);
//                                             return Text(
//                                               senderUser.username!,
//                                               style: TextStyle(
//                                                 color: Colors.white70,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             );
//                                           } else {
//                                             return SizedBox();
//                                           }
//                                         },
//                                       ),
//                                       SizedBox(height: 5),
//                                       Text(
//                                         currentMessage.text!,
//                                         style: TextStyle(
//                                             color: Colors.white, fontSize: 16),
//                                       ),
//                                       SizedBox(height: 5),
//                                       Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Text(
//                                             formatTimestamp(
//                                                 currentMessage.createdon!),
//                                             style: TextStyle(
//                                               color: Colors.white70,
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                           SizedBox(width: 5),
//                                           if (isSentByUser)
//                                             Icon(
//                                               currentMessage.seen!
//                                                   ? Icons.done_all
//                                                   : Icons.done,
//                                               size: 16,
//                                               color: Colors.white70,
//                                             ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         } else if (snapshot.hasError) {
//                           return Center(
//                             child: Text(
//                                 "An error occurred! Please check your internet connection."),
//                           );
//                         } else {
//                           return Center(
//                             child: Text("Say hi to your group"),
//                           );
//                         }
//                       } else {
//                         return Center(
//                           child: CircularProgressIndicator(),
//                         );
//                       }
//                     },
//                   ),
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//                 color: Colors.grey[200],
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: SingleChildScrollView(
//                         child: TextFormField(
//                           controller: messageController,
//                           maxLines: null,
//                           decoration: InputDecoration(
//                             constraints: BoxConstraints(maxHeight: 150),
//                             contentPadding: EdgeInsets.symmetric(
//                                 vertical: 10, horizontal: 15),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(25),
//                               borderSide: BorderSide.none,
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                             hintText: "Enter message",
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     GestureDetector(
//                       onTap: sendMessage,
//                       child: Container(
//                         padding: EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           gradient: LinearGradient(
//                             colors: [Colors.green, Colors.teal],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                         ),
//                         child: Icon(Icons.send, color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
