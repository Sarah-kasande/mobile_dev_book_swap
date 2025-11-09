import 'package:flutter/material.dart';
import 'dart:io';
import '../models/book_model.dart';
import '../services/book_service.dart';

class BookProvider with ChangeNotifier {
  final BookService _bookService = BookService();
  List<BookModel> _allBooks = [];
  List<BookModel> _userBooks = [];
  bool _isLoading = false;
  String? _error;

  List<BookModel> get allBooks => _allBooks;
  List<BookModel> get userBooks => _userBooks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenToAllBooks() {
    _bookService.getAllBooks().listen(
      (books) {
        print('BookProvider: Received ${books.length} books from stream');
        _allBooks = books;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('BookProvider: Error loading books: $error');
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
    _isLoading = true;
    notifyListeners();
  }

  Future<void> refreshAllBooks() async {
    try {
      _setLoading(true);
      _error = null;
      
      _allBooks = await _bookService.getAllBooksOnce();
      
      print('BookProvider: Directly fetched ${_allBooks.length} books');
      _setLoading(false);
    } catch (e) {
      print('BookProvider: Error refreshing books: $e');
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  void listenToUserBooks(String userId) {
    _bookService.getUserBooks(userId).listen((books) {
      _userBooks = books;
      notifyListeners();
    });
  }

  Future<bool> addBook(BookModel book, File? imageFile) async {
    try {
      _setLoading(true);
      _error = null;
      
      print('BookProvider: Adding book with title: ${book.title}');
      print('BookProvider: Has image: ${book.imageBase64 != null && book.imageBase64!.isNotEmpty}');
      
      String bookId = await _bookService.addBook(book, imageFile);
      print('BookProvider: Book added successfully with ID: $bookId');
      
      // Refresh both all books and user books
      await refreshAllBooks();
      
      _setLoading(false);
      return true;
    } catch (e) {
      print('BookProvider: Error adding book: $e');
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBook(String bookId, BookModel book, File? imageFile) async {
    try {
      _setLoading(true);
      _error = null;
      
      await _bookService.updateBook(bookId, book, imageFile);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBook(String bookId) async {
    try {
      _setLoading(true);
      _error = null;
      
      await _bookService.deleteBook(bookId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<BookModel?> getBook(String bookId) async {
    try {
      return await _bookService.getBook(bookId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}