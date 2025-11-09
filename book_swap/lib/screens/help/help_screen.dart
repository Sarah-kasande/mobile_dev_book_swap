import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'How to Use BookSwap',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              icon: Icons.library_add,
              title: '1. Add Your Books',
              description: 'Go to "My Books" tab and tap the + button to add books you want to swap. Include a photo and book details.',
              color: Colors.green,
            ),
            
            _buildSection(
              icon: Icons.search,
              title: '2. Browse Available Books',
              description: 'Use the "Browse" tab to find books you\'re interested in. Filter by condition or search by title/author.',
              color: Colors.blue,
            ),
            
            _buildSection(
              icon: Icons.swap_horiz,
              title: '3. Request a Swap',
              description: 'Found a book you like? Tap "Request Swap" to send a swap offer to the book owner.',
              color: Colors.orange,
            ),
            
            _buildSection(
              icon: Icons.notifications,
              title: '4. Manage Swap Offers',
              description: 'Check the "Swaps" tab to see incoming requests and manage your sent offers. Accept or reject as needed.',
              color: Colors.purple,
            ),
            
            _buildSection(
              icon: Icons.chat,
              title: '5. Chat with Other Users',
              description: 'Once a swap is accepted, use the chat feature to coordinate the book exchange with the other user.',
              color: Colors.teal,
            ),
            
            const SizedBox(height: 30),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    color: Colors.blue.shade600,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tips for Success',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Take clear photos of your books\n'
                    '• Be honest about book condition\n'
                    '• Respond promptly to swap requests\n'
                    '• Use chat to arrange safe meetups\n'
                    '• Be respectful to other users',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}