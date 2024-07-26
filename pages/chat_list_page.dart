import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agriclink/models/chat_list_entry.dart';
import 'chat_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Not logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('chatList')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var chats = snapshot.data!.docs
              .map((doc) => ChatListEntry.fromDocument(doc))
              .toList();

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              var chat = chats[index];

              return ListTile(
                leading: CircleAvatar(
                  child: Text(chat.userName[0]),
                ),
                title: Text(chat.userName),
                subtitle: Text('Last message: ${chat.lastMessage}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        chatId: chat.chatId,
                        productOwnerId: chat.userId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
