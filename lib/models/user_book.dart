import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ReadingStatus {
  wantToRead,
  reading,
  read,
}

class UserBook {
  final String id;
  final String userId;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String? bookCoverUrl;
  final ReadingStatus status;
  final bool isFavorite;
  final DateTime addedAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int? userRating;
  final String? notes;

  UserBook({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    this.bookCoverUrl,
    required this.status,
    this.isFavorite = false,
    required this.addedAt,
    this.startedAt,
    this.finishedAt,
    this.userRating,
    this.notes,
  });

  factory UserBook.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserBook(
      id: doc.id,
      userId: data['userId'] ?? '',
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      bookAuthor: data['bookAuthor'] ?? '',
      bookCoverUrl: data['bookCoverUrl'],
      status: ReadingStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ReadingStatus.wantToRead,
      ),
      isFavorite: data['isFavorite'] ?? false,
      addedAt: _parseTimestamp(data['addedAt']),
      startedAt: data['startedAt'] != null
          ? _parseTimestamp(data['startedAt'])
          : null,
      finishedAt: data['finishedAt'] != null
          ? _parseTimestamp(data['finishedAt'])
          : null,
      userRating: data['userRating'],
      notes: data['notes'],
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
      'userId': userId,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookCoverUrl': bookCoverUrl,
      'status': status.name,
      'isFavorite': isFavorite,
      'addedAt': addedAt.millisecondsSinceEpoch,
      'startedAt': startedAt?.millisecondsSinceEpoch,
      'finishedAt': finishedAt?.millisecondsSinceEpoch,
      'userRating': userRating,
      'notes': notes,
    };
  }

  UserBook copyWith({
    String? id,
    String? userId,
    String? bookId,
    String? bookTitle,
    String? bookAuthor,
    String? bookCoverUrl,
    ReadingStatus? status,
    bool? isFavorite,
    DateTime? addedAt,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? userRating,
    String? notes,
  }) {
    return UserBook(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      bookCoverUrl: bookCoverUrl ?? this.bookCoverUrl,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      addedAt: addedAt ?? this.addedAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      userRating: userRating ?? this.userRating,
      notes: notes ?? this.notes,
    );
  }

  String get statusDisplayName {
    switch (status) {
      case ReadingStatus.wantToRead:
        return 'Quiero leer';
      case ReadingStatus.reading:
        return 'Leyendo';
      case ReadingStatus.read:
        return 'Leído';
    }
  }

  Color get statusColor {
    switch (status) {
      case ReadingStatus.wantToRead:
        return const Color(0xFF2196F3);
      case ReadingStatus.reading:
        return const Color(0xFFFF9800);
      case ReadingStatus.read:
        return const Color(0xFF4CAF50);
    }
  }
}