import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agriclink/models/chat_message.dart';
import 'package:agriclink/models/chat_list_entry.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String productOwnerId;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.productOwnerId,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) {
      return;
    }

    var user = _auth.currentUser;
    if (user == null) {
      // Handle the case where the user is not logged in
      return;
    }

    var message = ChatMessage(
      id: '',
      text: _controller.text.trim(),
      senderId: user.uid,
      senderName: user.displayName ?? 'Anonymous',
      timestamp: Timestamp.now(),
    );

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add(message.toMap());

    // Update chat lists for both users
    await _updateChatList(user.uid, widget.productOwnerId, message);
    await _updateChatList(widget.productOwnerId, user.uid, message);

    _controller.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _updateChatList(
      String userId, String otherUserId, ChatMessage message) async {
    var otherUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .get();
    if (!otherUserDoc.exists) return;

    var otherUserName =
        otherUserDoc['username']; // Ensure the correct field name

    var chatListEntry = ChatListEntry(
      chatId: widget.chatId,
      userId: otherUserId,
      userName: otherUserName,
      lastMessage: message.text,
      timestamp: message.timestamp,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chatList')
        .doc(otherUserId)
        .set(chatListEntry.toMap());
  }

  void _sendAudioMessage() {
    // Logic to send audio message
  }

  void _deleteMessage(String messageId) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  void _forwardMessage(ChatMessage message) {
    // Logic to forward message
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatroom'),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // Logic to start a call
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // Logic to start a video call
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.lightGreen[100], // Light green background color
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.chatId)
                    .collection('messages')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var messages = snapshot.data!.docs
                      .map((doc) => ChatMessage.fromDocument(doc))
                      .toList();

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      var isMe = message.senderId == _auth.currentUser?.uid;
                      return GestureDetector(
                        onLongPress: () {
                          // Show options to delete or forward the message
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.delete),
                                    title: const Text('Delete'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _deleteMessage(message.id);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.forward),
                                    title: const Text('Forward'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _forwardMessage(message);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color:
                                      isMe ? Colors.green[300] : Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 3.0,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.text,
                                      style: TextStyle(
                                        color:
                                            isMe ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      DateFormat('h:mm a')
                                          .format(message.timestamp.toDate()),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isMe
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isMe)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    message.senderName,
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: _sendAudioMessage,
                    color: Colors.green,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter your message...',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
