import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_chat/Others/contacts_screen.dart';
import 'package:just_chat/Profile%20Management/edit_profile_screen.dart';
import 'package:just_chat/Others/search_screen.dart';
import 'package:just_chat/Others/welcome_screen.dart';
import 'package:just_chat/notification_services.dart';

import '../Helper/firebase_helper.dart';
import '../Models/chat_room_model.dart';
import '../Models/message_model.dart';
import '../Models/user_model.dart';
import '../Others/Animation.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const ChatListScreen({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {

  void logOut(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'isOnline': false});

      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
          SlidePageRoute(
              page: WelcomeScreen()
          )
          , (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.green,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userModel.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text(
                "Welcome,",
                style: TextStyle(color: Colors.white),
              );
            }

            var userDoc = snapshot.data!;
            String username = userDoc['username'] ?? "Name";

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome,",
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(width: 4,),
                Container(
                  width: 100,
                  child: Text(
                    username,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'Edit Profile':
                  Navigator.push(
                    context,
                    SlidePageRoute(
                      page: EditProfileScreen(userModel: widget.userModel),
                    ),
                  );
                  break;
                case 'My Contacts':
                  Navigator.push(
                    context,
                    SlidePageRoute(
                      page: ContactsScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'Edit Profile',
                  child: Text('Edit Profile'),
                ),
                PopupMenuItem(
                  value: 'My Contacts',
                  child: Text('My Contacts'),
                ),
              ];
            },
          ),
        ],
      ),

      drawer: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userModel.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var userDoc = snapshot.data!;
            String username = userDoc['username'] ?? "Username";
            String email = userDoc['email'] ?? "Email";
            String phone = userDoc['phonenumber'] ?? "No number";
            String about = userDoc['about'] ?? "How is your mood today?";
            String profileImage = userDoc['profile'] ?? "";

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Container(
                    width: 180,
                    child: Text(username,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          color: Colors.white
                      ),
                    ),
                  ),
                  accountEmail: Text(email,
                    style: TextStyle(
                        color: Colors.white
                    ),),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: NetworkImage(profileImage),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.teal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person, color: Colors.green,),
                  title: Text("Username"),
                  subtitle: Text(username,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: Colors.grey
                    ),),
                ),
                ListTile(
                  leading: Icon(Icons.email, color: Colors.green,),
                  title: Text("Email"),
                  subtitle: Text(email,
                    style: TextStyle(
                        color: Colors.grey
                    ),),
                ),
                ListTile(
                  leading: Icon(Icons.phone, color: Colors.green,),
                  title: Text("Phone Number"),
                  subtitle: Text(phone,
                    style: TextStyle(
                        color: Colors.grey
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.notes, color: Colors.green,),
                  title: Text("About"),
                  subtitle: Text(about,
                    style: TextStyle(
                        color: Colors.grey
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              )
                          ),
                          onPressed: () async {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Log out',
                                        style: TextStyle(fontSize: 18, color: Colors.red)),
                                    content: Row(
                                      children: [
                                        Text('Are you sure you want to\nLog out?'),
                                      ],
                                    ),
                                    actions: [
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5),
                                              )
                                          ),
                                          onPressed: () async {
                                            logOut(context);
                                          },
                                          child: Text('Yes', style: TextStyle(color: Colors.white),)
                                      ),
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5),
                                              )
                                          ),
                                          onPressed: (){
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            'No ',
                                            style: TextStyle(color: Colors.white),)
                                      )
                                    ],
                                  );
                                }
                            );
                          },
                          child: Text('Log out', style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [

            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .where("participants.${widget.userModel.uid}", isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;

                      if (chatRoomSnapshot.docs.isNotEmpty) {
                        return ListView.builder(
                          itemCount: chatRoomSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                                chatRoomSnapshot.docs[index].data() as Map<String, dynamic>);

                            Map<String, dynamic> participants = chatRoomModel.participants!;
                            List<String> participantKeys = participants.keys.toList();
                            participantKeys.remove(widget.userModel.uid);

                            return FutureBuilder(
                              future: FirebaseHelper.getUserModelById(participantKeys[0]),
                              builder: (context, userData) {
                                if (userData.connectionState == ConnectionState.done) {
                                  if (userData.data != null) {
                                    UserModel targetUser = userData.data as UserModel;

                                    return StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection("chatrooms")
                                          .doc(chatRoomModel.chatroomId)
                                          .collection("messages")
                                          .orderBy("createdon", descending: true)
                                          .limit(1)
                                          .snapshots(),
                                      builder: (context, messageSnapshot) {
                                        if (messageSnapshot.connectionState == ConnectionState.active) {
                                          if (messageSnapshot.hasData) {
                                            QuerySnapshot messageDataSnapshot = messageSnapshot.data as QuerySnapshot;

                                            if (messageDataSnapshot.docs.isNotEmpty) {
                                              MessageModel lastMessage = MessageModel.fromMap(
                                                  messageDataSnapshot.docs[0].data() as Map<String, dynamic>);

                                              // Format the timestamp
                                              String formattedTime = DateFormat('h:mm a').format(lastMessage.createdon!.toDate());

                                              return Padding(
                                                padding: const EdgeInsets.only(top: 10),
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  elevation: 4,
                                                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                                  child: ListTile(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        SlidePageRoute(
                                                          page: ChatScreen(
                                                            chatroom: chatRoomModel,
                                                            firebaseUser: widget.firebaseUser,
                                                            userModel: widget.userModel,
                                                            targetUser: targetUser,
                                                          )
                                                        ),
                                                      );
                                                    },
                                                    leading: CircleAvatar(
                                                      backgroundImage: NetworkImage(targetUser.profile.toString()),
                                                      radius: 25,
                                                    ),
                                                    title: Text(
                                                      targetUser.username.toString(),
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    subtitle: Text(
                                                      lastMessage.text.toString(),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(color: Colors.grey),
                                                    ),
                                                    trailing: Text(
                                                      formattedTime,
                                                      style: TextStyle(color: Colors.grey),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                elevation: 4,
                                                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                                child: ListTile(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      SlidePageRoute(
                                                          page: ChatScreen(
                                                            chatroom: chatRoomModel,
                                                            firebaseUser: widget.firebaseUser,
                                                            userModel: widget.userModel,
                                                            targetUser: targetUser,
                                                          )
                                                      ),
                                                    );
                                                  },
                                                  leading: CircleAvatar(
                                                    backgroundImage: NetworkImage(targetUser.profile.toString()),
                                                    radius: 25,
                                                  ),
                                                  title: Text(
                                                    targetUser.username.toString(),
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  subtitle: Text(
                                                    'Say \"Hello\" to your new friend!',
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(color: Colors.black54),
                                                  ),
                                                  trailing: Icon(Icons.keyboard_arrow_right)
                                                ),
                                              );
                                            }
                                          } else if (messageSnapshot.hasError) {
                                            return Center(
                                              child: Text("Error loading last message"),
                                            );
                                          } else {
                                            return Center(
                                              child: Text("No messages found"),
                                            );
                                          }
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                      },
                                    );
                                  } else {
                                    return Text('Nothing to show!');
                                  }
                                } else {
                                  return Container();
                                }
                              },
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: Text("No Recent Chats Available!"),
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return Center(
                        child: Text("No Chats"),
                      );
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: () {
          Navigator.push(context, SlidePageRoute(
            page: SearchScreen(
                userModel: widget.userModel, firebaseUser: widget.firebaseUser)
          ));
        },
        child: Icon(
          Icons.search,
          color: Colors.white,
        ),
      ),
    );
  }
}