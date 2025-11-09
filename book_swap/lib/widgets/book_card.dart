import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/book_model.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback? onTap;
  final VoidCallback? onSwapPressed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;
  final bool showSwapButton;
  final bool showEditButton;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onSwapPressed,
    this.onEditPressed,
    this.onDeletePressed,
    this.showSwapButton = false,
    this.showEditButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.blue.shade100,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Book Image
              Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade100,
                      Colors.blue.shade200,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildBookImage(),
              ),
              
              const SizedBox(width: 16),
              
              // Book Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'by ${book.author}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Condition Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getConditionColor(book.condition).withOpacity(0.8),
                            _getConditionColor(book.condition),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _getConditionColor(book.condition).withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        book.conditionString,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Owner: ${book.ownerName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    
                    if (!book.isAvailable) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Swap Pending',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action Buttons
              Column(
                children: [
                  if (showSwapButton && book.isAvailable)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade500, Colors.blue.shade700],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: onSwapPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Text(
                          'Swap',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  
                  if (showEditButton) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: onEditPressed,
                        icon: Icon(Icons.edit_rounded, color: Colors.blue.shade600),
                        iconSize: 18,
                        tooltip: 'Edit Book',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: onDeletePressed,
                        icon: Icon(Icons.delete_rounded, color: Colors.red.shade600),
                        iconSize: 18,
                        tooltip: 'Delete Book',
                      ),
                    ),
                  ],
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildBookImage() {
    // Display base64 image if available
    if (book.imageBase64 != null && book.imageBase64!.isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(book.imageBase64!),
            width: 80,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          ),
        );
      } catch (e) {
        return _buildPlaceholder();
      }
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getColorFromTitle(book.title).withOpacity(0.8),
            _getColorFromTitle(book.title),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              book.title.length > 15 ? book.title.substring(0, 15) + '...' : book.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromTitle(String title) {
    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.purple.shade600,
      Colors.orange.shade600,
      Colors.red.shade600,
      Colors.teal.shade600,
      Colors.indigo.shade600,
      Colors.brown.shade600,
    ];
    
    final hash = title.hashCode;
    return colors[hash.abs() % colors.length];
  }

  Color _getConditionColor(BookCondition condition) {
    switch (condition) {
      case BookCondition.newBook:
        return Colors.green;
      case BookCondition.likeNew:
        return Colors.blue;
      case BookCondition.good:
        return Colors.orange;
      case BookCondition.used:
        return Colors.red;
    }
  }
}