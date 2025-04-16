import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderId,
      'senderEmail': receiverID,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
