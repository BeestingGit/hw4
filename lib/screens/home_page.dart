import 'package:flutter/material.dart';
import 'chat_page.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> messageBoards = [
    {"name": "General", "icon": Icons.chat},
    {"name": "Work", "icon": Icons.work},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Message Boards")),
      body: ListView.builder(
        itemCount: messageBoards.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(messageBoards[index]["icon"]),
            title: Text(messageBoards[index]["name"]),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) =>
                            ChatPage(boardName: messageBoards[index]["name"]),
                  ),
                ),
          );
        },
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text("Menu")),
            ListTile(title: Text("Profile"), onTap: () {}),
            ListTile(title: Text("Settings"), onTap: () {}),
          ],
        ),
      ),
    );
  }
}
