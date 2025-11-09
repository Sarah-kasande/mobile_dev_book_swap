import 'package:flutter/material.dart';
import 'dart:async';
import '../models/swap_model.dart';
import '../services/swap_service.dart';

class SwapProvider with ChangeNotifier {
  final SwapService _swapService = SwapService();
  List<SwapModel> _userSwaps = [];
  List<SwapModel> _receivedSwaps = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<SwapModel>>? _swapSubscription;

  List<SwapModel> get userSwaps => _userSwaps;
  List<SwapModel> get receivedSwaps => _receivedSwaps;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenToUserSwaps(String userId) {
    _swapSubscription?.cancel();
    _swapSubscription = _swapService.getAllUserSwaps(userId).listen(
      (swaps) {
        print('SwapProvider: Received ${swaps.length} swaps for user $userId');
        _userSwaps = swaps.where((swap) => swap.requesterId == userId).toList();
        _receivedSwaps = swaps.where((swap) => swap.ownerId == userId).toList();
        print('SwapProvider: User swaps: ${_userSwaps.length}, Received swaps: ${_receivedSwaps.length}');
        notifyListeners();
      },
      onError: (error) {
        print('SwapProvider: Error listening to swaps: $error');
        _error = error.toString();
        notifyListeners();
      },
    );
  }



  @override
  void dispose() {
    _swapSubscription?.cancel();
    super.dispose();
  }

  Future<bool> createSwapOffer(SwapModel swap) async {
    try {
      _setLoading(true);
      _error = null;
      
      print('SwapProvider: Creating swap offer for book ${swap.bookTitle}');
      
      String swapId = await _swapService.createSwapOffer(swap);
      print('SwapProvider: Swap created successfully with ID: $swapId');
      
      _setLoading(false);
      return true;
    } catch (e) {
      print('SwapProvider: Error creating swap: $e');
      _error = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSwapStatus(String swapId, SwapStatus status) async {
    try {
      _setLoading(true);
      _error = null;
      
      await _swapService.updateSwapStatus(swapId, status);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  List<SwapModel> get pendingReceivedSwaps {
    return _receivedSwaps.where((swap) => swap.status == SwapStatus.pending).toList();
  }

  List<SwapModel> get acceptedSwaps {
    return [..._userSwaps, ..._receivedSwaps]
        .where((swap) => swap.status == SwapStatus.accepted)
        .toList();
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