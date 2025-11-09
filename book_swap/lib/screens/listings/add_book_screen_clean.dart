import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AddBookScreenClean extends StatefulWidget {
  const AddBookScreenClean({super.key});

  @override
  State<AddBookScreenClean> createState() => _AddBookScreenCleanState();
}

class _AddBookScreenCleanState extends State<AddBookScreenClean> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  
  int _selectedCondition = 0;
  File? _selectedImage;
  bool _isUploading = false;
  bool _isSaving = false;

  final List<String> _conditions = ['New', 'Like New', 'Good', 'Used'];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker Section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _buildImageWidget(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Book Title *',
                  prefixIcon: const Icon(Icons.book),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
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
                  labelText: 'Author *',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the author name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Condition Dropdown
              DropdownButtonFormField<int>(
                value: _selectedCondition,
                decoration: InputDecoration(
                  labelText: 'Condition',
                  prefixIcon: const Icon(Icons.star),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _conditions.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value ?? 0;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Save Button
              ElevatedButton(
                onPressed: _isSaving ? null : _saveBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Saving...'),
                        ],
                      )
                    : const Text(
                        'Save Book',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // Info Text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Image is optional. You can add it now or later.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_isUploading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Processing image...'),
          ],
        ),
      );
    }

    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: kIsWeb
            ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
            : Image.file(_selectedImage!, fit: BoxFit.cover),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to add book cover\n(Optional)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      setState(() {
        _isUploading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final fileName = 'books/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);

      final uploadTask = await ref.putFile(_selectedImage!);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      setState(() {
        _isUploading = false;
      });

      return downloadUrl;
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isSaving = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Please log in to add books');
      }

      // Upload image if selected
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
      }

      // Save book to Firestore
      await FirebaseFirestore.instance.collection('books').add({
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'condition': _selectedCondition,
        'imageUrl': imageUrl, // This will be null if no image was uploaded
        'ownerId': user.uid,
        'ownerName': user.displayName ?? user.email ?? 'Unknown',
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
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}