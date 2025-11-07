import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createChatRoom(String swapId, List<String> participants, List<String> participantNames) async {
    try {
      String chatRoomId = '${participants[0]}_${participants[1]}_$swapId';
      
      ChatRoom chatRoom = ChatRoom(
        id: chatRoomId,
        participants: participants,
        participantNames: participantNames,
        swapId: swapId,
      );

      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .set(chatRoom.toMap());

      return chatRoomId;
    } catch (e) {
      throw e;
    }
  }

  Stream<List<ChatRoom>> getUserChatRooms(String userId) {
    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ChatMessage>> getChatMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendMessage(String chatRoomId, ChatMessage message) async {
    try {
      // Add message to subcollection
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(message.toMap());

      // Update chat room with last message info
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .update({
        'lastMessage': message.message,
        'lastMessageTime': message.timestamp.millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<String?> getChatRoomForSwap(String swapId, String userId1, String userId2) async {
    try {
      String chatRoomId1 = '${userId1}_${userId2}_$swapId';
      String chatRoomId2 = '${userId2}_${userId1}_$swapId';

      DocumentSnapshot doc1 = await _firestore.collection('chatRooms').doc(chatRoomId1).get();
      if (doc1.exists) return chatRoomId1;

      DocumentSnapshot doc2 = await _firestore.collection('chatRooms').doc(chatRoomId2).get();
      if (doc2.exists) return chatRoomId2;

      return null;
    } catch (e) {
      return null;
    }
  }
}