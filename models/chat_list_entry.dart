import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListEntry {
  final String chatId;
  final String userId;
  final String userName;
  final String lastMessage;
  final Timestamp timestamp;

  ChatListEntry({
    required this.chatId,
    required this.userId,
    required this.userName,
    required this.lastMessage,
    required this.timestamp,
  });

  factory ChatListEntry.fromDocument(DocumentSnapshot doc) {
    return ChatListEntry(
      chatId: doc['chatId'],
      userId: doc['userId'],
      userName: doc['userName'],
      lastMessage: doc['lastMessage'],
      timestamp: doc['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'userId': userId,
      'userName': userName,
      'lastMessage': lastMessage,
      'timestamp': timestamp,
    };
  }
}
