import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/message_service.dart';
import '../models/message_board.dart';
import 'board_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MessageService _messageService = MessageService();
  List<MessageBoard> _messageBoards = [];
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = context.read<AuthService>();
      final userData = await authService.getCurrentUserData();

      setState(() {
        _userData = userData;
        _messageBoards = _messageService.getMessageBoards();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Message Boards')),
      drawer: Drawer(child: _buildDrawer()),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _buildMessageBoardsList(),
    );
  }

  Widget _buildDrawer() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(
            _userData != null
                ? '${_userData!['firstName']} ${_userData!['lastName']}'
                : 'User',
          ),
          accountEmail: Text(_userData != null ? _userData!['email'] : ''),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              _userData != null
                  ? _userData!['firstName'][0].toUpperCase()
                  : 'U',
              style: TextStyle(fontSize: 40.0),
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.dashboard),
          title: Text('Message Boards'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Profile'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileScreen()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            );
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Logout'),
          onTap: () async {
            Navigator.pop(context);
            await context.read<AuthService>().signOut();
          },
        ),
      ],
    );
  }

  Widget _buildMessageBoardsList() {
    return ListView.builder(
      itemCount: _messageBoards.length,
      itemBuilder: (context, index) {
        final board = _messageBoards[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(_getIconData(board.imageIcon), color: Colors.white),
            ),
            title: Text(
              board.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BoardScreen(board: board)),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'chat':
        return Icons.chat;
      case 'computer':
        return Icons.computer;
      case 'sports_basketball':
        return Icons.sports_basketball;
      case 'movie':
        return Icons.movie;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'music_note':
        return Icons.music_note;
      default:
        return Icons.forum;
    }
  }
}
