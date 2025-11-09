import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/swap_model.dart';

class SwapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Clean up old rejected/completed swaps for a book to allow new requests
  Future<void> cleanupOldSwaps(String bookId, String userId) async {
    try {
      QuerySnapshot oldSwaps = await _firestore
          .collection('swaps')
          .where('bookId', isEqualTo: bookId)
          .where('requesterId', isEqualTo: userId)
          .where('status', whereIn: [SwapStatus.rejected.index, SwapStatus.completed.index])
          .get();
      
      for (var doc in oldSwaps.docs) {
        await doc.reference.delete();
        print('SwapService: Cleaned up old swap ${doc.id}');
      }
    } catch (e) {
      print('SwapService: Error cleaning up old swaps: $e');
    }
  }

  Future<String> createSwapOffer(SwapModel swap) async {
    try {
      print('SwapService: Creating swap offer...');
      print('SwapService: Requester: ${swap.requesterName} (${swap.requesterId})');
      print('SwapService: Book: ${swap.bookTitle} (${swap.bookId})');
      
      // Basic validation
      if (swap.requesterId.isEmpty || swap.ownerId.isEmpty || swap.bookId.isEmpty) {
        throw Exception('Invalid swap data: missing required fields');
      }
      
      if (swap.requesterId == swap.ownerId) {
        throw Exception('Cannot create swap with yourself');
      }
      
      // Create swap offer directly - let multiple requests exist
      Map<String, dynamic> swapData = swap.toMap();
      print('SwapService: Creating swap with data: $swapData');
      
      DocumentReference docRef = await _firestore
          .collection('swaps')
          .add(swapData);
      
      print('SwapService: Swap created successfully with ID: ${docRef.id}');

      return docRef.id;
    } catch (e) {
      print('SwapService: Error creating swap: $e');
      if (e.toString().contains('permission-denied')) {
        throw Exception('Permission denied. Please make sure you are logged in.');
      }
      throw Exception('Failed to create swap request. Please try again.');
    }
  }

  Stream<List<SwapModel>> getUserSwaps(String userId) {
    return _firestore
        .collection('swaps')
        .where('requesterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<List<SwapModel>> getReceivedSwaps(String userId) {
    return _firestore
        .collection('swaps')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> updateSwapStatus(String swapId, SwapStatus status) async {
    try {
      print('SwapService: Updating swap $swapId to status ${status.name}');
      
      // Get swap document first
      DocumentSnapshot swapDoc = await _firestore.collection('swaps').doc(swapId).get();
      if (!swapDoc.exists) {
        throw Exception('Swap not found');
      }
      
      SwapModel swap = SwapModel.fromMap(swapDoc.data() as Map<String, dynamic>, swapId);
      
      // Update swap status
      await _firestore.collection('swaps').doc(swapId).update({
        'status': status.index,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      
      print('SwapService: Swap status updated successfully');

      // Update book availability based on status
      if (status == SwapStatus.rejected || status == SwapStatus.completed) {
        await _firestore
            .collection('books')
            .doc(swap.bookId)
            .update({'isAvailable': true});
        print('SwapService: Book made available again');
      }
    } catch (e) {
      print('SwapService: Error updating swap status: $e');
      if (e.toString().contains('permission-denied')) {
        throw Exception('Permission denied. You can only update your own swaps.');
      }
      throw Exception('Failed to update swap status: ${e.toString()}');
    }
  }

  Stream<List<SwapModel>> getAllUserSwaps(String userId) {
    return _firestore
        .collection('swaps')
        .snapshots()
        .map((snapshot) {
      List<SwapModel> allSwaps = [];
      
      for (var doc in snapshot.docs) {
        try {
          var data = doc.data() as Map<String, dynamic>;
          var swap = SwapModel.fromMap(data, doc.id);
          
          // Include swaps where user is either requester or owner
          if (swap.requesterId == userId || swap.ownerId == userId) {
            allSwaps.add(swap);
          }
        } catch (e) {
          print('Error processing swap document ${doc.id}: $e');
        }
      }
      
      allSwaps.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allSwaps;
    });
  }
}