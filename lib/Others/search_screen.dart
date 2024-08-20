import 'dart:developer';

import 'package:just_chat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Models/chat_room_model.dart';
import '../Models/user_model.dart';
import '../Chat Screens/chat_screen.dart';
import 'animation.dart';

class SearchScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchScreen({super.key, required this.userModel, required this.firebaseUser});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {

      // Fetching the existing chatroom
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom = ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;
    } else {

      // Creating new chatroom
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomId: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomId)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;

      log("New Chatroom Created!");
    }

    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.green,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text("Search", style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              TextFormField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("username", isEqualTo: searchController.text)
                    .where("username", isNotEqualTo: widget.userModel.username)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                      if (dataSnapshot.docs.isNotEmpty) {
                        Map<String, dynamic> userMap = dataSnapshot.docs[0].data() as Map<String, dynamic>;

                        UserModel searchedUser = UserModel.fromMap(userMap);

                        return Card(
                          color: Colors.green,
                          elevation: 4,
                          child: ListTile(
                            onTap: () async {
                              setState(() {
                                isLoading = true;
                              });

                              ChatRoomModel? chatroomModel = await getChatroomModel(searchedUser);

                              setState(() {
                                isLoading = false;
                              });

                              if (chatroomModel != null) {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  SlidePageRoute(
                                    page: ChatScreen(
                                      targetUser: searchedUser,
                                      userModel: widget.userModel,
                                      firebaseUser: widget.firebaseUser,
                                      chatroom: chatroomModel,
                                    )
                                  ),
                                );
                              }
                            },
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(searchedUser.profile!),
                              backgroundColor: Colors.grey[500],
                            ),
                            title: Text(searchedUser.username!, style: const TextStyle(color: Colors.white),),
                            subtitle: Text(searchedUser.email!, style: const TextStyle(color: Colors.white70),),
                            trailing: isLoading
                                ? const CircularProgressIndicator()
                                : const Icon(Icons.keyboard_arrow_right, color: Colors.white,),
                          ),
                        );
                      } else {
                        return const Text("No results found!");
                      }
                    } else if (snapshot.hasError) {
                      return const Text("An error occurred!");
                    } else {
                      return const Text("No results found!");
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
