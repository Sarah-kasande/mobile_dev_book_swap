import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/swap_provider.dart';
import '../../models/book_model.dart';
import '../../models/swap_model.dart';
import '../../widgets/book_card.dart';
import '../../services/sample_data_service.dart';
import 'book_detail_screen.dart';

class BrowseListingsScreen extends StatefulWidget {
  const BrowseListingsScreen({super.key});

  @override
  State<BrowseListingsScreen> createState() => _BrowseListingsScreenState();
}

class _BrowseListingsScreenState extends State<BrowseListingsScreen> {
  String _searchQuery = '';
  BookCondition? _selectedCondition;

  @override
  void initState() {
    super.initState();
    // Load books when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      bookProvider.listenToAllBooks();
      bookProvider.refreshAllBooks(); // Also try direct fetch
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Browse Books',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              final bookProvider = Provider.of<BookProvider>(context, listen: false);
              bookProvider.refreshAllBooks();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.blue.shade600,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          
          // Filter Chips
          if (_selectedCondition != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Chip(
                    label: Text(_selectedCondition!.name),
                    onDeleted: () {
                      setState(() {
                        _selectedCondition = null;
                      });
                    },
                    backgroundColor: Colors.blue.shade100,
                    deleteIconColor: Colors.blue.shade600,
                  ),
                ],
              ),
            ),
          
          // Books List
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, bookProvider, child) {
                // Debug: Print the number of books
                print('Total books loaded: ${bookProvider.allBooks.length}');
                
                List<BookModel> filteredBooks = bookProvider.allBooks.where((book) {
                  final matchesSearch = book.title.toLowerCase().contains(_searchQuery) ||
                      book.author.toLowerCase().contains(_searchQuery);
                  final matchesCondition = _selectedCondition == null || book.condition == _selectedCondition;
                  return matchesSearch && matchesCondition;
                }).toList();

                if (bookProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (filteredBooks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          bookProvider.allBooks.isEmpty ? 'No books available yet' : 'No books found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bookProvider.allBooks.isEmpty 
                            ? 'Get started by adding some sample books using the button below!' 
                            : 'Try adjusting your search or filters',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    return BookCard(
                      book: book,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailScreen(book: book),
                          ),
                        );
                      },
                      showSwapButton: true,
                      onSwapPressed: () => _showSwapDialog(book),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          // Only show the FAB when there are no books
          if (bookProvider.allBooks.isEmpty && !bookProvider.isLoading) {
            return FloatingActionButton.extended(
              onPressed: _addSampleBooks,
              icon: const Icon(Icons.add),
              label: const Text('Add Sample Books'),
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _addSampleBooks() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Adding sample books...'),
          ],
        ),
      ),
    );

    try {
      await SampleDataService.addSampleBooks();
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Refresh book list
        final bookProvider = Provider.of<BookProvider>(context, listen: false);
        await bookProvider.refreshAllBooks();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sample books added successfully! Check them out below.'),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding sample books: $e'),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Books'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Condition:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...BookCondition.values.map((condition) => RadioListTile<BookCondition>(
              title: Text(condition.name),
              value: condition,
              groupValue: _selectedCondition,
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value;
                });
                Navigator.pop(context);
              },
            )),
            ListTile(
              title: const Text('Clear Filter'),
              onTap: () {
                setState(() {
                  _selectedCondition = null;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSwapDialog(BookModel book) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user?.uid == book.ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot swap your own book'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Book Swap'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Do you want to request a swap for "${book.title}"?'),
            const SizedBox(height: 16),
            Text(
              'Owner: ${book.ownerName}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text('Condition: ${book.conditionString}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _requestSwap(book),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Request Swap'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestSwap(BookModel book) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);
    
    if (authProvider.user == null) return;

    SwapModel swap = SwapModel(
      id: '',
      requesterId: authProvider.user!.uid,
      requesterName: authProvider.user!.displayName,
      ownerId: book.ownerId,
      ownerName: book.ownerName,
      bookId: book.id,
      bookTitle: book.title,
      status: SwapStatus.pending,
      createdAt: DateTime.now(),
    );

    Navigator.pop(context);
    
    print('Attempting to create swap for book: ${book.title} (${book.id})');
    bool success = await swapProvider.createSwapOffer(swap);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Swap request sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(swapProvider.error ?? 'Failed to send swap request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}