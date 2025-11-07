import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/swap_model.dart';

class SwapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createSwapOffer(SwapModel swap) async {
    try {
      // Create swap offer
      DocumentReference docRef = await _firestore
          .collection('swaps')
          .add(swap.toMap());

      // Update book availability
      await _firestore
          .collection('books')
          .doc(swap.bookId)
          .update({'isAvailable': false});

      return docRef.id;
    } catch (e) {
      throw e;
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
      await _firestore.collection('swaps').doc(swapId).update({
        'status': status.index,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // If rejected, make book available again
      if (status == SwapStatus.rejected) {
        DocumentSnapshot swapDoc = await _firestore.collection('swaps').doc(swapId).get();
        if (swapDoc.exists) {
          SwapModel swap = SwapModel.fromMap(swapDoc.data() as Map<String, dynamic>, swapId);
          await _firestore
              .collection('books')
              .doc(swap.bookId)
              .update({'isAvailable': true});
        }
      }
    } catch (e) {
      throw e;
    }
  }

  Stream<List<SwapModel>> getAllUserSwaps(String userId) {
    return _firestore
        .collection('swaps')
        .where('requesterId', isEqualTo: userId)
        .snapshots()
        .asyncMap((requestedSnapshot) async {
      List<SwapModel> requestedSwaps = requestedSnapshot.docs
          .map((doc) => SwapModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      QuerySnapshot receivedSnapshot = await _firestore
          .collection('swaps')
          .where('ownerId', isEqualTo: userId)
          .get();

      List<SwapModel> receivedSwaps = receivedSnapshot.docs
          .map((doc) => SwapModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      List<SwapModel> allSwaps = [...requestedSwaps, ...receivedSwaps];
      allSwaps.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return allSwaps;
    });
  }
}