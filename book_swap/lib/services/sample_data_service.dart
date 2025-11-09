import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';
import '../services/book_service.dart';

class SampleDataService {
  static final BookService _bookService = BookService();

  static Future<void> addSampleBooks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final sampleBooks = [
      {
        'title': 'The Great Gatsby',
        'author': 'F. Scott Fitzgerald',
        'condition': BookCondition.good,
      },
      {
        'title': 'To Kill a Mockingbird',
        'author': 'Harper Lee',
        'condition': BookCondition.likeNew,
      },
      {
        'title': '1984',
        'author': 'George Orwell',
        'condition': BookCondition.used,
      },
      {
        'title': 'Pride and Prejudice',
        'author': 'Jane Austen',
        'condition': BookCondition.good,
      },
      {
        'title': 'The Catcher in the Rye',
        'author': 'J.D. Salinger',
        'condition': BookCondition.newBook,
      },
      {
        'title': 'Lord of the Flies',
        'author': 'William Golding',
        'condition': BookCondition.used,
      },
      {
        'title': 'Animal Farm',
        'author': 'George Orwell',
        'condition': BookCondition.likeNew,
      },
      {
        'title': 'Brave New World',
        'author': 'Aldous Huxley',
        'condition': BookCondition.good,
      },
      {
        'title': 'The Hobbit',
        'author': 'J.R.R. Tolkien',
        'condition': BookCondition.newBook,
      },
      {
        'title': 'Harry Potter and the Sorcerer\'s Stone',
        'author': 'J.K. Rowling',
        'condition': BookCondition.likeNew,
      },
    ];

    for (final bookData in sampleBooks) {
      try {
        final book = BookModel(
          id: '',
          title: bookData['title'] as String,
          author: bookData['author'] as String,
          condition: bookData['condition'] as BookCondition,
          imageBase64: null, // Let the widget handle the beautiful placeholder
          ownerId: user.uid,
          ownerName: user.displayName ?? user.email ?? 'Anonymous',
          createdAt: DateTime.now().subtract(Duration(days: sampleBooks.indexOf(bookData))),
          isAvailable: true,
        );

        await _bookService.addBook(book, null);
        print('Added sample book: ${book.title}');
      } catch (e) {
        print('Error adding sample book ${bookData['title']}: $e');
      }
    }
  }

  static Future<void> addAdditionalBooks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final additionalBooks = [
      {
        'title': 'Dune',
        'author': 'Frank Herbert',
        'condition': BookCondition.good,
      },
      {
        'title': 'The Hitchhiker\'s Guide to the Galaxy',
        'author': 'Douglas Adams',
        'condition': BookCondition.used,
      },
      {
        'title': 'Foundation',
        'author': 'Isaac Asimov',
        'condition': BookCondition.likeNew,
      },
      {
        'title': 'Ender\'s Game',
        'author': 'Orson Scott Card',
        'condition': BookCondition.newBook,
      },
      {
        'title': 'The Martian',
        'author': 'Andy Weir',
        'condition': BookCondition.good,
      },
      {
        'title': 'Ready Player One',
        'author': 'Ernest Cline',
        'condition': BookCondition.used,
      },
      {
        'title': 'The Time Machine',
        'author': 'H.G. Wells',
        'condition': BookCondition.used,
      },
      {
        'title': 'Fahrenheit 451',
        'author': 'Ray Bradbury',
        'condition': BookCondition.good,
      },
    ];

    for (final bookData in additionalBooks) {
      try {
        final book = BookModel(
          id: '',
          title: bookData['title'] as String,
          author: bookData['author'] as String,
          condition: bookData['condition'] as BookCondition,
          imageBase64: null, // Let the widget handle the beautiful placeholder
          ownerId: user.uid,
          ownerName: user.displayName ?? user.email ?? 'Anonymous',
          createdAt: DateTime.now().subtract(Duration(days: additionalBooks.indexOf(bookData) + 20)),
          isAvailable: true,
        );

        await _bookService.addBook(book, null);
        print('Added additional book: ${book.title}');
      } catch (e) {
        print('Error adding additional book ${bookData['title']}: $e');
      }
    }
  }

  // Simple method to just add books without images initially
  static Future<void> addBasicSampleBooks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final basicBooks = [
      {
        'title': 'The Great Gatsby',
        'author': 'F. Scott Fitzgerald',
        'condition': BookCondition.good,
      },
      {
        'title': 'To Kill a Mockingbird',
        'author': 'Harper Lee',
        'condition': BookCondition.likeNew,
      },
      {
        'title': '1984',
        'author': 'George Orwell',
        'condition': BookCondition.used,
      },
      {
        'title': 'Pride and Prejudice',
        'author': 'Jane Austen',
        'condition': BookCondition.good,
      },
      {
        'title': 'The Catcher in the Rye',
        'author': 'J.D. Salinger',
        'condition': BookCondition.newBook,
      },
    ];

    for (final bookData in basicBooks) {
      try {
        final book = BookModel(
          id: '',
          title: bookData['title'] as String,
          author: bookData['author'] as String,
          condition: bookData['condition'] as BookCondition,
          imageBase64: null, // No image initially
          ownerId: user.uid,
          ownerName: user.displayName ?? user.email ?? 'Anonymous',
          createdAt: DateTime.now().subtract(Duration(days: basicBooks.indexOf(bookData))),
          isAvailable: true,
        );

        await _bookService.addBook(book, null);
        print('Added basic book: ${book.title}');
      } catch (e) {
        print('Error adding basic book ${bookData['title']}: $e');
      }
    }
  }
}
