import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatelessWidget {
  final String boardName;

  ChatPage({required this.boardName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(boardName)),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection("messages")
                .where("boardId", isEqualTo: boardName)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final messages = snapshot.data!.docs;

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return ListTile(
                title: Text(message["content"]),
                subtitle: Text(
                  "${message["username"]} • ${message["datetime"].toDate()}",
                ),
              );
            },
          );
        },
      ),
    );
  }
}
