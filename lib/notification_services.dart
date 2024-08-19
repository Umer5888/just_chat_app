// import 'dart:math';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:just_chat/Chat%20Screens/chat_screen.dart';
//
// import '../Models/chat_room_model.dart';
// import '../Models/user_model.dart';
// import '../main.dart';
//
// class NotificationServices {
//
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   void iniLocalNotifications(BuildContext context,
//       RemoteMessage message) async {
//     var androidInitialize = const AndroidInitializationSettings(
//         '@mipmap/ic_launcher');
//     var initializeSettings = InitializationSettings(
//         android: androidInitialize
//     );
//     await flutterLocalNotificationsPlugin.initialize(
//       initializeSettings,
//       onDidReceiveNotificationResponse: (payload) {
//         handleIncomingMessages(context, message);
//       },
//     );
//   }
//
//   void requestNotificationPermissions() async {
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       announcement: true,
//       badge: true,
//       carPlay: true,
//       criticalAlert: true,
//       provisional: true,
//       sound: true,
//     );
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('Permission granted');
//     } else
//     if (settings.authorizationStatus == AuthorizationStatus.provisional) {
//       print('Permission provisional granted');
//     } else {
//       print('Permission denied');
//     }
//   }
//
//   void firebaseInit(BuildContext context) {
//     FirebaseMessaging.onMessage.listen((message) {
//       if (kDebugMode) {
//         print(message.notification!.title.toString());
//         print(message.notification!.body.toString());
//       }
//       showNotification(message);
//       iniLocalNotifications(context, message);
//     });
//   }
//
//   Future<void> showNotification(RemoteMessage message) async {
//     AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(
//       Random.secure().nextInt(1000).toString(),
//       'Special Notifications',
//       importance: Importance.max,
//     );
//
//     AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
//       androidNotificationChannel.id.toString(),
//       androidNotificationChannel.name.toString(),
//       channelDescription: 'Just the Description',
//       importance: Importance.high,
//       priority: Priority.high,
//       ticker: 'ticker',
//       icon: '@mipmap/ic_launcher',
//     );
//
//     NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//     );
//
//     Future.delayed(Duration.zero, () {
//       flutterLocalNotificationsPlugin.show(
//         1,
//         message.notification!.title.toString(),
//         message.notification!.body.toString(),
//         notificationDetails,
//       );
//     });
//   }
//
//   Future<String?> getDeviceToken() async {
//     String? token = await messaging.getToken();
//     return token;
//   }
//
//   void isTokenRefresh() {
//     messaging.onTokenRefresh.listen((event) {
//       event.toString();
//     });
//   }
//
//   Future<void> handleIncomingMessages(BuildContext context, RemoteMessage message) async {
//     try {
//       // Get the current user
//       User? firebaseUser = FirebaseAuth.instance.currentUser;
//
//       if (firebaseUser == null) {
//         throw Exception('No user is currently signed in.');
//       }
//
//       // Fetch UserModel for the current user
//       DocumentSnapshot currentUserSnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(firebaseUser.uid)
//           .get();
//
//       if (!currentUserSnapshot.exists) {
//         throw Exception('Current user not found');
//       }
//
//       UserModel currentUser = UserModel.fromMap(
//           currentUserSnapshot.data() as Map<String, dynamic>);
//
//       // Extract target user ID from notification data
//       String targetUserId = message.data['targetUserId'];
//
//       // Fetch UserModel for target user
//       DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(targetUserId)
//           .get();
//       if (!userSnapshot.exists) {
//         throw Exception('Target user not found');
//       }
//       UserModel targetUser = UserModel.fromMap(
//           userSnapshot.data() as Map<String, dynamic>);
//
//       // Fetch all chatrooms for the current user
//       QuerySnapshot chatroomsSnapshot = await FirebaseFirestore.instance
//           .collection('chatrooms')
//           .where("participants.${firebaseUser.uid}", isEqualTo: true)
//           .get();
//
//       ChatRoomModel? chatroomModel;
//
//       for (var doc in chatroomsSnapshot.docs) {
//         ChatRoomModel chatRoom = ChatRoomModel.fromMap(
//             doc.data() as Map<String, dynamic>);
//
//         if (chatRoom.participants!.containsKey(targetUserId)) {
//           chatroomModel = chatRoom;
//           break;
//         }
//       }
//
//       if (chatroomModel == null) {
//         chatroomModel = await getChatroomModel(targetUser, currentUser);
//       }
//
//       // Navigate to ChatScreen with the retrieved data
//       if (chatroomModel != null && message.data['type'] == 'message') {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 ChatScreen(
//                   id: message.data['id'],
//                   targetUser: targetUser,
//                   chatroom: chatroomModel,
//                   userModel: currentUser,
//                   firebaseUser: firebaseUser,
//                 ),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error handling incoming message: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to open chat.')),
//       );
//     }
//   }
//
//   // void handleIncomingMessages(BuildContext context, RemoteMessage message){
//   //   if(message.data['type'] == 'message'){
//   //     Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(
//   //       id: message.data['id'],
//   //     )));
//   //   }
//   //
//   // }
//
//
//   Future<ChatRoomModel?> getChatroomModel(UserModel targetUser,
//       UserModel currentUser) async {
//     ChatRoomModel? chatRoom;
//
//     QuerySnapshot snapshot = await FirebaseFirestore.instance
//         .collection("chatrooms")
//         .where("participants.${currentUser.uid}", isEqualTo: true)
//         .where("participants.${targetUser.uid}", isEqualTo: true)
//         .get();
//
//     if (snapshot.docs.isNotEmpty) {
//       var docData = snapshot.docs[0].data();
//       ChatRoomModel existingChatroom = ChatRoomModel.fromMap(
//           docData as Map<String, dynamic>);
//       chatRoom = existingChatroom;
//     } else {
//       ChatRoomModel newChatroom = ChatRoomModel(
//         chatroomId: uuid.v1(),
//         lastMessage: "",
//         participants: {
//           currentUser.uid.toString(): true,
//           targetUser.uid.toString(): true,
//         },
//       );
//
//       await FirebaseFirestore.instance
//           .collection("chatrooms")
//           .doc(newChatroom.chatroomId)
//           .set(newChatroom.toMap());
//
//       chatRoom = newChatroom;
//       log("New Chatroom Created!" as num);
//     }
//
//     return chatRoom;
//   }
// }
