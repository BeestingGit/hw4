import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../models/message_board.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all message boards (hardcoded as per requirements)
  List<MessageBoard> getMessageBoards() {
    return [
      MessageBoard(
        id: 'general',
        name: 'General Discussion',
        imageIcon: 'chat',
      ),
      MessageBoard(id: 'tech', name: 'Technology', imageIcon: 'computer'),
      MessageBoard(
        id: 'sports',
        name: 'Sports',
        imageIcon: 'sports_basketball',
      ),
      MessageBoard(id: 'movies', name: 'Movies & TV', imageIcon: 'movie'),
      MessageBoard(id: 'gaming', name: 'Gaming', imageIcon: 'sports_esports'),
      MessageBoard(id: 'music', name: 'Music', imageIcon: 'music_note'),
    ];
  }

  // Get messages for a specific board
  Stream<List<MessageModel>> getMessagesForBoard(String boardId) {
    return _firestore
        .collection('messageBoards')
        .doc(boardId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList();
        });
  }

  // Send a message
  Future<void> sendMessage(
    String boardId,
    String message,
    String userId,
    String username,
  ) async {
    await _firestore
        .collection('messageBoards')
        .doc(boardId)
        .collection('messages')
        .add({
          'messageText': message,
          'userId': userId,
          'username': username,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }
}
