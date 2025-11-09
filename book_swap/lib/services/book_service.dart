import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/book_model.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Test Firebase Storage connectivity
  Future<bool> testStorageConnection() async {
    try {
      // Try to get a reference to test storage access
      final ref = _storage.ref().child('test/connection_test.txt');
      print('BookService: Storage reference created successfully');
      return true;
    } catch (e) {
      print('BookService: Storage connection test failed: $e');
      return false;
    }
  }

  Stream<List<BookModel>> getAllBooks() {
    return _firestore
        .collection('books')
        .snapshots()
        .map((snapshot) {
          print('BookService: Received ${snapshot.docs.length} documents from Firestore');
          List<BookModel> books = [];
          for (var doc in snapshot.docs) {
            try {
              print('BookService: Processing document ${doc.id} with data: ${doc.data()}');
              var book = BookModel.fromMap(doc.data(), doc.id);
              if (book.isAvailable) {
                books.add(book);
              }
            } catch (e) {
              print('BookService: Error processing document ${doc.id}: $e');
            }
          }
          // Sort in memory instead of using orderBy
          books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return books;
        });
  }

  Stream<List<BookModel>> getUserBooks(String userId) {
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<String> addBook(BookModel book, File? imageFile) async {
    try {
      print('BookService: Adding book with image: ${book.imageBase64 != null}');
      
      Map<String, dynamic> bookData = {
        'title': book.title,
        'author': book.author,
        'condition': book.condition.index,
        'ownerId': book.ownerId,
        'ownerName': book.ownerName,
        'createdAt': book.createdAt.millisecondsSinceEpoch,
        'isAvailable': book.isAvailable,
      };
      
      // Add image if available
      if (book.imageBase64 != null && book.imageBase64!.isNotEmpty) {
        bookData['imageBase64'] = book.imageBase64;
        print('BookService: Image added to book data');
      }
      
      DocumentReference docRef = await _firestore.collection('books').add(bookData);
      
      print('BookService: Book added successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('BookService: Error adding book: $e');
      throw e;
    }
  }

  Future<void> updateBook(String bookId, BookModel book, File? imageFile) async {
    try {
      print('BookService: Updating book $bookId');
      
      await _firestore
          .collection('books')
          .doc(bookId)
          .update(book.toMap());
      
      print('BookService: Book updated successfully');
    } catch (e) {
      print('BookService: Error updating book: $e');
      throw e;
    }
  }

  Future<void> deleteBook(String bookId) async {
    await _firestore.collection('books').doc(bookId).delete();
  }

  Future<BookModel?> getBook(String bookId) async {
    DocumentSnapshot doc = await _firestore.collection('books').doc(bookId).get();
    if (doc.exists) {
      return BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<List<BookModel>> getAllBooksOnce() async {
    QuerySnapshot snapshot = await _firestore
        .collection('books')
        .get();
    
    List<BookModel> books = [];
    for (var doc in snapshot.docs) {
      try {
        print('BookService: Direct fetch - processing document ${doc.id}');
        var book = BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        if (book.isAvailable) {
          books.add(book);
        }
      } catch (e) {
        print('BookService: Error in direct fetch for document ${doc.id}: $e');
      }
    }
    
    // Sort by creation date
    books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return books;
  }
}