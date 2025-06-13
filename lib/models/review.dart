import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String bookId;
  final String userId;
  final String userEmail;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userEmail,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      rating: data['rating'] ?? 0,
      comment: data['comment'],
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    
    try {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      } else {
        return DateTime.now();
      }
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookId': bookId,
      'userId': userId,
      'userEmail': userEmail,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  Review copyWith({
    String? id,
    String? bookId,
    String? userId,
    String? userEmail,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}