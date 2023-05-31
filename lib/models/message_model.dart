import 'dart:convert';

class Message {
  int senderID;
  int receiverID;
  String message;
  String? sentAt;

  Message({
        this.senderID = 0,
        this.receiverID = 0,
        this.message = "",
        this.sentAt,
    });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderID'],
      receiverID: map['receiverID'],
      message: map['message'],
      sentAt: map['sentAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'receiverID': receiverID,
      'message': message,
      'sentAt': sentAt,
    };
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) => Message.fromMap(json.decode(source));
}