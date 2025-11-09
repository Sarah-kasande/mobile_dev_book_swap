import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/book_model.dart';

class EditBookScreen extends StatefulWidget {
  final BookModel book;

  const EditBookScreen({super.key, required this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late BookCondition _selectedCondition;
  String _imageBase64 = '';
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _selectedCondition = widget.book.condition;
    _imageBase64 = widget.book.imageBase64 ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Book',
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
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _isUploading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : _imageBase64.isNotEmpty
                              ? Image.memory(
                                  base64Decode(_imageBase64),
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.book, size: 80),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Book Title',
                      prefixIcon: const Icon(Icons.book_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the book title';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Author Field
                  TextFormField(
                    controller: _authorController,
                    decoration: InputDecoration(
                      labelText: 'Author',
                      prefixIcon: const Icon(Icons.person_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the author name';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Condition Dropdown
                  DropdownButtonFormField<BookCondition>(
                    value: _selectedCondition,
                    decoration: InputDecoration(
                      labelText: 'Condition',
                      prefixIcon: const Icon(Icons.star_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: BookCondition.values.map((condition) {
                      return DropdownMenuItem(
                        value: condition,
                        child: Text(_getConditionString(condition)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCondition = value;
                        });
                      }
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Update Book Button
                  ElevatedButton(
                    onPressed: bookProvider.isLoading ? null : _updateBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: bookProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Update Book',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      String base64Image;

      if (kIsWeb) {
        // Web: Read directly
        final bytes = await picked.readAsBytes();
        base64Image = base64Encode(bytes);
      } else {
        // Mobile: Compress before encoding
        final file = File(picked.path);
        final compressed = await FlutterImageCompress.compressAndGetFile(
          file.path,
          '${file.path}_compressed.jpg',
          quality: 70,
          minWidth: 800,
          minHeight: 800,
        );
        base64Image = base64Encode(await compressed!.readAsBytes());
      }

      setState(() {
        _imageBase64 = base64Image;
        _isUploading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed')),
        );
      }
      setState(() => _isUploading = false);
    }
  }

  Future<void> _updateBook() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      
      if (authProvider.user == null) return;

      BookModel updatedBook = BookModel(
        id: widget.book.id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        condition: _selectedCondition,
        imageBase64: _imageBase64.isNotEmpty ? _imageBase64 : null,
        ownerId: widget.book.ownerId,
        ownerName: widget.book.ownerName,
        createdAt: widget.book.createdAt,
        isAvailable: widget.book.isAvailable,
      );

      bool success = await bookProvider.updateBook(widget.book.id, updatedBook, null);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bookProvider.error ?? 'Failed to update book'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getConditionString(BookCondition condition) {
    switch (condition) {
      case BookCondition.newBook:
        return 'New';
      case BookCondition.likeNew:
        return 'Like New';
      case BookCondition.good:
        return 'Good';
      case BookCondition.used:
        return 'Used';
    }
  }
}