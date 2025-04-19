import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String messageText;
  final String userId;
  final String username;
  final Timestamp timestamp;

  MessageModel({
    required this.id,
    required this.messageText,
    required this.userId,
    required this.username,
    required this.timestamp,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      messageText: data['messageText'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageText': messageText,
      'userId': userId,
      'username': username,
      'timestamp': timestamp,
    };
  }
}
