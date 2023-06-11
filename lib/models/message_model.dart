import 'dart:convert';
import 'package:rnt_app/utils/utils.dart';
class Message {
  int messageID;
  int createdByID;
  int CreatorCustomerID;
  String FirstName;
  String LastName;
  String createDate;
  String subject;
  String messageBody;
  String expiryDate;
  bool isReminder;
  String nextReminderDate;
  int messageStatusID;
  String messageStatusDescription;
  int recieptStatusID;
  String recieptStatusDescription;
  int recipientID;

  Message({
    this.messageID = -1,
    this.createdByID = -1,
    this.CreatorCustomerID = -1,
    this.FirstName = "",
    this.LastName = "",
    this.createDate = "",
    this.subject= "",
    this.messageBody = "",
    this.expiryDate = "",
    this.isReminder = false,
    this.nextReminderDate = "",
    this.messageStatusID = 0,
    this.messageStatusDescription = "",
    this.recieptStatusID = 0,
    this.recieptStatusDescription = "",
    this.recipientID = -1,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageID: map['messageID'] ?? -1,
      createdByID: map['createdByID'] ?? -1,
      CreatorCustomerID: map['CreatorCustomerID'] ?? -1,
      FirstName: map['FirstName'] ?? "",
      LastName: map['LastName'] ?? "",
      createDate: convertUTC2Local(map['createDate'] ?? ""),
      subject: map['subject'] ?? "",
      messageBody: map['messageBody'] ?? "",
      expiryDate: convertUTC2Local(map['expiryDate'] ?? ""),
      isReminder: map['isReminder'] ?? false,
      nextReminderDate: convertUTC2Local(map['nextReminderDate'] ?? ""),
      messageStatusID: map['messageStatusID'] ?? 1,
      messageStatusDescription: map['messageStatusDescription'] ?? "",
      recieptStatusID: map['recieptStatusID'] ?? 1,
      recieptStatusDescription: map['recieptStatusDescription'] ?? "",
      recipientID: map['recipientID'] ?? -1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageID': messageID,
      'createdByID': createdByID,
      'CreatorCustomerID': CreatorCustomerID,
      'FirstName': FirstName,
      'LastName': LastName,
      'createDate': createDate,
      'subject': subject,
      'messageBody': messageBody,
      'expiryDate': expiryDate,
      'isReminder': isReminder,
      'nextReminderDate': nextReminderDate,
      'messageStatusID': messageStatusID,
      'messageStatusDescription': messageStatusDescription,
      'recieptStatusID': recieptStatusID,
      'recieptStatusDescription': recieptStatusDescription,
      'recipientID': recipientID,
    };
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) => Message.fromMap(json.decode(source));
}