import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/book_model.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  BookCondition _selectedCondition = BookCondition.good;
  String _imageBase64 = '';
  bool _isUploading = false;

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
          'Add Book',
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
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    base64Decode(_imageBase64),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to add book cover',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
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
                  
                  // Add Book Button
                  ElevatedButton(
                    onPressed: _isUploading ? null : _addBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Add Book',
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
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (picked == null) return;

      setState(() => _isUploading = true);

      // Read image bytes
      final bytes = await picked.readAsBytes();
      
      // Convert to base64
      final base64String = base64Encode(bytes);
      
      print('Image picked and encoded. Size: ${bytes.length} bytes');
      
      setState(() {
        _imageBase64 = base64String;
        _isUploading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image selected successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error picking image: $e');
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addBook() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.user == null) return;

      try {
        setState(() => _isUploading = true);
        
        // Save directly to Firestore with base64 image
        await FirebaseFirestore.instance.collection('books').add({
          'title': _titleController.text.trim(),
          'author': _authorController.text.trim(),
          'condition': _selectedCondition.index,
          'imageBase64': _imageBase64.isNotEmpty ? _imageBase64 : null,
          'ownerId': authProvider.user!.uid,
          'ownerName': authProvider.user!.displayName ?? authProvider.user!.email ?? 'Unknown User',
          'createdAt': FieldValue.serverTimestamp(),
          'isAvailable': true,
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding book: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
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