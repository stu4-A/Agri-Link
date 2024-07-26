import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final Timestamp timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  factory ChatMessage.fromDocument(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp,
    };
  }
}
