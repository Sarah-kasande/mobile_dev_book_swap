import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/swap_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/swap_model.dart';
import '../chat/chat_screen.dart';

class SwapOffersScreen extends StatefulWidget {
  const SwapOffersScreen({super.key});

  @override
  State<SwapOffersScreen> createState() => _SwapOffersScreenState();
}

class _SwapOffersScreenState extends State<SwapOffersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Swap Offers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Debug info
          Consumer2<SwapProvider, AuthProvider>(
            builder: (context, swapProvider, authProvider, child) {
              return Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey.shade100,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Received: ${swapProvider.receivedSwaps.length}'),
                        Text('Sent: ${swapProvider.userSwaps.length}'),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            if (authProvider.user != null) {
                              print('Refreshing swaps for user: ${authProvider.user!.uid}');
                              swapProvider.listenToUserSwaps(authProvider.user!.uid);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear_all),
                          onPressed: () async {
                            if (authProvider.user != null) {
                              await _clearOldSwaps(authProvider.user!.uid);
                            }
                          },
                          tooltip: 'Clear old swaps',
                        ),
                      ],
                    ),
                    if (swapProvider.error != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.red.shade100,
                        child: Text(
                          'Error: ${swapProvider.error}',
                          style: TextStyle(color: Colors.red.shade800, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReceivedOffersTab(),
                _buildSentOffersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedOffersTab() {
    return Consumer<SwapProvider>(
      builder: (context, swapProvider, child) {
        if (swapProvider.receivedSwaps.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swap_horiz_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No swap offers received',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: swapProvider.receivedSwaps.length,
          itemBuilder: (context, index) {
            final swap = swapProvider.receivedSwaps[index];
            return _buildSwapCard(swap, isReceived: true);
          },
        );
      },
    );
  }

  Widget _buildSentOffersTab() {
    return Consumer<SwapProvider>(
      builder: (context, swapProvider, child) {
        if (swapProvider.userSwaps.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.send_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No swap offers sent',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: swapProvider.userSwaps.length,
          itemBuilder: (context, index) {
            final swap = swapProvider.userSwaps[index];
            return _buildSwapCard(swap, isReceived: false);
          },
        );
      },
    );
  }

  Widget _buildSwapCard(SwapModel swap, {required bool isReceived}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        swap.bookTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isReceived 
                            ? 'Requested by: ${swap.requesterName}'
                            : 'Owner: ${swap.ownerName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(swap.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStatusColor(swap.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    swap.statusString,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(swap.status),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Requested on ${DateFormat('MMM dd, yyyy').format(swap.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            
            if (swap.updatedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Updated on ${DateFormat('MMM dd, yyyy').format(swap.updatedAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                if (isReceived && swap.status == SwapStatus.pending) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateSwapStatus(swap, SwapStatus.rejected),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Reject',
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateSwapStatus(swap, SwapStatus.accepted),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
                
                if (swap.status == SwapStatus.accepted) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openChat(swap),
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text('Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(SwapStatus status) {
    switch (status) {
      case SwapStatus.pending:
        return Colors.orange;
      case SwapStatus.accepted:
        return Colors.green;
      case SwapStatus.rejected:
        return Colors.red;
      case SwapStatus.completed:
        return Colors.blue;
    }
  }

  Future<void> _updateSwapStatus(SwapModel swap, SwapStatus status) async {
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);
    
    bool success = await swapProvider.updateSwapStatus(swap.id, status);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Swap ${status.name}d successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // If accepted, create chat room
      if (status == SwapStatus.accepted) {
        _createChatRoom(swap);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(swapProvider.error ?? 'Failed to update swap status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createChatRoom(SwapModel swap) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    await chatProvider.createChatRoom(
      swap.id,
      [swap.requesterId, swap.ownerId],
      [swap.requesterName, swap.ownerName],
    );
  }

  Future<void> _openChat(SwapModel swap) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    if (authProvider.user == null) return;
    
    String? chatRoomId = await chatProvider.getChatRoomForSwap(
      swap.id,
      swap.requesterId,
      swap.ownerId,
    );
    
    if (chatRoomId == null) {
      chatRoomId = await chatProvider.createChatRoom(
        swap.id,
        [swap.requesterId, swap.ownerId],
        [swap.requesterName, swap.ownerName],
      );
    }
    
    if (chatRoomId != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatRoomId: chatRoomId!,
            otherUserName: authProvider.user!.uid == swap.requesterId 
                ? swap.ownerName 
                : swap.requesterName,
          ),
        ),
      );
    }
  }

  Future<void> _clearOldSwaps(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Get all rejected/completed swaps for this user
      QuerySnapshot oldSwaps = await firestore
          .collection('swaps')
          .where('requesterId', isEqualTo: userId)
          .where('status', whereIn: [SwapStatus.rejected.index, SwapStatus.completed.index])
          .get();
      
      for (var doc in oldSwaps.docs) {
        await doc.reference.delete();
        print('Cleared old swap: ${doc.id}');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cleared ${oldSwaps.docs.length} old swaps'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error clearing old swaps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing old swaps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}