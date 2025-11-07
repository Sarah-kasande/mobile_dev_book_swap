import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/book_model.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<BookModel>> getAllBooks() {
    return _firestore
        .collection('books')
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromMap(doc.data(), doc.id))
            .toList());
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
      String? imageUrl;
      
      if (imageFile != null) {
        String fileName = 'books/${DateTime.now().millisecondsSinceEpoch}.jpg';
        UploadTask uploadTask = _storage.ref().child(fileName).putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      BookModel bookWithImage = BookModel(
        id: '',
        title: book.title,
        author: book.author,
        condition: book.condition,
        imageUrl: imageUrl,
        ownerId: book.ownerId,
        ownerName: book.ownerName,
        createdAt: book.createdAt,
        isAvailable: book.isAvailable,
      );

      DocumentReference docRef = await _firestore
          .collection('books')
          .add(bookWithImage.toMap());
      
      return docRef.id;
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateBook(String bookId, BookModel book, File? imageFile) async {
    try {
      String? imageUrl = book.imageUrl;
      
      if (imageFile != null) {
        String fileName = 'books/${DateTime.now().millisecondsSinceEpoch}.jpg';
        UploadTask uploadTask = _storage.ref().child(fileName).putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      BookModel updatedBook = BookModel(
        id: book.id,
        title: book.title,
        author: book.author,
        condition: book.condition,
        imageUrl: imageUrl,
        ownerId: book.ownerId,
        ownerName: book.ownerName,
        createdAt: book.createdAt,
        isAvailable: book.isAvailable,
      );

      await _firestore
          .collection('books')
          .doc(bookId)
          .update(updatedBook.toMap());
    } catch (e) {
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
}