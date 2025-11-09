import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/book_provider.dart';
import '../../widgets/book/book_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../browse/book_detail_screen.dart';
import '../../widgets/book/featured_gallery.dart';

/// Home screen showing all books
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2196F3), // Beautiful blue like in your image
              Color(0xFF1976D2), // Darker blue for depth
              Color(0xFF0D47A1), // Deep blue at bottom
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Browse Books',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        // Real-time updates are automatic, so just show a refresh animation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Books updated automatically!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Add filter functionality
                      },
                      icon: const Icon(
                        Icons.filter_list,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Search Bar
              GestureDetector(
                onTap: () {
                  // Show message to use Browse tab for search
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tap "Browse" tab below to search books'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Search books...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Content Area
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Consumer<BookProvider>(
                    builder: (context, bookProvider, _) {
                      final books = bookProvider.allBooks;

                      if (bookProvider.isLoading && books.isEmpty) {
                        return const LoadingIndicator(message: 'Loading books...');
                      }

                      return ListView(
                        padding: const EdgeInsets.only(top: 20),
                        children: [
                          const FeaturedGallery(title: 'Featured'),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'All Books',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (books.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                              child: Center(child: Text('No books yet. Post your first book!')),
                            )
                          else
                            ...books.map((book) => BookCard(
                                  book: book,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookDetailScreen(book: book),
                                      ),
                                    );
                                  },
                                  showOwner: true,
                                )),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
