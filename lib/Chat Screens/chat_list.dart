import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
import '../Others/animation.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const ChatListScreen({super.key, required this.userModel, required this.firebaseUser});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {

  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestNotificationPermissions();
    notificationServices.firebaseInit(context);
    notificationServices.getDeviceToken().then((value) {
      if (kDebugMode) {
        print('device token');
        print(value);
      }
    });

  }

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
              page: const WelcomeScreen()
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
          decoration: const BoxDecoration(
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
              return const Text(
                "Welcome,",
                style: TextStyle(color: Colors.white),
              );
            }

            var userDoc = snapshot.data!;
            String username = userDoc['username'] ?? "Name";

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome,",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 4,),
                SizedBox(
                  width: 100,
                  child: Text(
                    username,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
        iconTheme: const IconThemeData(
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
                      page: const ContactsScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'Edit Profile',
                  child: Text('Edit Profile'),
                ),
                const PopupMenuItem(
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
              return const Center(child: CircularProgressIndicator());
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
                  accountName: SizedBox(
                    width: 180,
                    child: Text(username,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                          color: Colors.white
                      ),
                    ),
                  ),
                  accountEmail: Text(email,
                    style: const TextStyle(
                        color: Colors.white
                    ),),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: NetworkImage(profileImage),
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.teal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.green,),
                  title: const Text("Username"),
                  subtitle: Text(username,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                        color: Colors.grey
                    ),),
                ),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.green,),
                  title: const Text("Email"),
                  subtitle: Text(email,
                    style: const TextStyle(
                        color: Colors.grey
                    ),),
                ),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.green,),
                  title: const Text("Phone Number"),
                  subtitle: Text(phone,
                    style: const TextStyle(
                        color: Colors.grey
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.notes, color: Colors.green,),
                  title: const Text("About"),
                  subtitle: Text(about,
                    style: const TextStyle(
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
                                    title: const Text('Log out',
                                        style: TextStyle(fontSize: 18, color: Colors.red)),
                                    content: const Row(
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
                                          child: const Text('Yes', style: TextStyle(color: Colors.white),)
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
                                          child: const Text(
                                            textAlign: TextAlign.center,
                                            'No ',
                                            style: TextStyle(color: Colors.white),)
                                      )
                                    ],
                                  );
                                }
                            );
                          },
                          child: const Text('Log out', style: TextStyle(color: Colors.white),),
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

            const SizedBox(height: 10),
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

                                              String formattedTime = DateFormat('h:mm a').format(lastMessage.createdon!.toDate());

                                              return Card(
                                                color: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                elevation: 4,
                                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                                  ),
                                                  subtitle: Text(
                                                    lastMessage.text.toString(),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(color: Colors.white70),
                                                  ),
                                                  trailing: Text(
                                                    formattedTime,
                                                    style: const TextStyle(color: Colors.white70),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Card(
                                                surfaceTintColor: Colors.blueGrey,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                elevation: 4,
                                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  subtitle: const Text(
                                                    'Say "Hello" to your new friend!',
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(color: Colors.black54),
                                                  ),
                                                  trailing: const Icon(Icons.keyboard_arrow_right)
                                                ),
                                              );
                                            }
                                          } else if (messageSnapshot.hasError) {
                                            return const Center(
                                              child: Text("Error loading last message"),
                                            );
                                          } else {
                                            return const Center(
                                              child: Text("No messages found"),
                                            );
                                          }
                                        } else {
                                          return const Column(
                                            children: [
                                              Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    );
                                  } else {
                                    return const Text('Nothing to show!');
                                  }
                                } else {
                                  return Container();
                                }
                              },
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text("No Recent Chats Available!"),
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return const Center(
                        child: Text("No Chats"),
                      );
                    }
                  } else {
                    return const Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
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
        child: const Icon(
          Icons.search,
          color: Colors.white,
        ),
      ),
    );
  }
}