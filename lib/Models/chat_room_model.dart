import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  String? chatroomId;
  Map<String, dynamic>? participants;
  String? lastMessage;
  Timestamp? orderChats;
  bool? isGroup;
  String? groupName;
  String? groupIcon;

  ChatRoomModel({
    this.chatroomId,
    this.participants,
    this.lastMessage,
    this.orderChats,
    this.isGroup = false,
    this.groupName,
    this.groupIcon
  });

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomId = map['chatroomId'];
    participants = map['participants'];
    lastMessage = map['lastMessage'];
    orderChats = map['orderChats'];
    isGroup = map['isGroup'] ?? false;
    groupName = map['groupName'];
    groupIcon = map['groupIcon'];
  }

  Map<String, dynamic> toMap() {
    return {
      'chatroomId': chatroomId,
      'participants': participants,
      'lastMessage': lastMessage,
      'orderChats': orderChats,
      'isGroup': isGroup,
      'groupName': groupName,
      'groupIcon' : groupIcon,
    };
  }
}
