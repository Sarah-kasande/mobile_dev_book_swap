enum BookCondition { newBook, likeNew, good, used }

class BookModel {
  final String id;
  final String title;
  final String author;
  final BookCondition condition;
  final String? imageUrl;
  final String? imageBase64;
  final String ownerId;
  final String ownerName;
  final DateTime createdAt;
  final bool isAvailable;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    this.imageUrl,
    this.imageBase64,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
    this.isAvailable = true,
  });

  factory BookModel.fromMap(Map<String, dynamic> map, String id) {
    return BookModel(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      condition: BookCondition.values[map['condition'] ?? 0],
      imageUrl: map['imageUrl'],
      imageBase64: map['imageBase64'],
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'condition': condition.index,
      'imageUrl': imageUrl,
      'imageBase64': imageBase64,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isAvailable': isAvailable,
    };
  }

  String get conditionString {
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