import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel{

  String? messageId;
  String? sender;
  String? text;
  bool? seen;
  Timestamp? createdon;

  MessageModel({this.sender, this.text, this.createdon, this.seen, this.messageId});

  MessageModel.fromMap(Map<String, dynamic> map) {

    sender = map['sender'];
    text = map['text'];
    seen = map['seen'];
    createdon = map['createdon'];
    messageId = map['messageId'];
  }

  Map<String, dynamic> toMap (){
    return {
      'sender' : sender,
      'text' : text,
      'seen' : seen,
      'createdon' : createdon,
      'messageId' : messageId,
    };
  }

}