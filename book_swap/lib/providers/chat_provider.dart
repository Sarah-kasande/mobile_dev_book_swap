import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<ChatRoom> _chatRooms = [];
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ChatRoom> get chatRooms => _chatRooms;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenToChatRooms(String userId) {
    _chatService.getUserChatRooms(userId).listen((chatRooms) {
      _chatRooms = chatRooms;
      notifyListeners();
    });
  }

  void listenToChatMessages(String chatRoomId) {
    _chatService.getChatMessages(chatRoomId).listen((messages) {
      _messages = messages;
      notifyListeners();
    });
  }

  Future<String?> createChatRoom(String swapId, List<String> participants, List<String> participantNames) async {
    try {
      _setLoading(true);
      _error = null;
      
      String chatRoomId = await _chatService.createChatRoom(swapId, participants, participantNames);
      _setLoading(false);
      return chatRoomId;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return null;
    }
  }

  Future<bool> sendMessage(String chatRoomId, ChatMessage message) async {
    try {
      await _chatService.sendMessage(chatRoomId, message);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<String?> getChatRoomForSwap(String swapId, String userId1, String userId2) async {
    return await _chatService.getChatRoomForSwap(swapId, userId1, userId2);
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}