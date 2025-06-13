import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';
import '../models/user_book.dart';

class UserBooksService {
  late final FirebaseFirestore _firestore;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _userBooksCollection = 'user_books';

  UserBooksService() {
    _firestore = FirebaseFirestore.instance;
    
    try {
      _firestore.settings = const Settings(
        persistenceEnabled: false,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      print('Error configurando Firestore: $e');
    }
  }

  Future<void> addBookToLibrary({
    required Book book,
    required ReadingStatus status,
    bool isFavorite = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final now = DateTime.now();
    final userBook = UserBook(
      id: '',
      userId: user.uid,
      bookId: book.id,
      bookTitle: book.title,
      bookAuthor: book.author,
      bookCoverUrl: book.coverUrl,
      status: status,
      isFavorite: isFavorite,
      addedAt: now,
      startedAt: status == ReadingStatus.reading ? now : null,
      finishedAt: status == ReadingStatus.read ? now : null,
    );

    await _firestore.collection(_userBooksCollection).add(userBook.toFirestore());
  }

  Future<void> updateBookStatus({
    required String userBookId,
    required ReadingStatus status,
    int? userRating,
    String? notes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final now = DateTime.now();
    final updateData = <String, dynamic>{
      'status': status.name,
    };

    if (status == ReadingStatus.reading) {
      updateData['startedAt'] = now.millisecondsSinceEpoch;
    }

    if (status == ReadingStatus.read) {
      updateData['finishedAt'] = now.millisecondsSinceEpoch;
      if (userRating != null) {
        updateData['userRating'] = userRating;
      }
    }

    if (notes != null) {
      updateData['notes'] = notes;
    }

    await _firestore
        .collection(_userBooksCollection)
        .doc(userBookId)
        .update(updateData);
  }

  Future<void> toggleFavorite(String userBookId, bool isFavorite) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _firestore
        .collection(_userBooksCollection)
        .doc(userBookId)
        .update({'isFavorite': isFavorite});
  }

  Future<void> removeBookFromLibrary(String userBookId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _firestore.collection(_userBooksCollection).doc(userBookId).delete();
  }

  Stream<List<UserBook>> getUserBooks({ReadingStatus? status}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    Query query = _firestore
        .collection(_userBooksCollection)
        .where('userId', isEqualTo: user.uid);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    return query
        .snapshots()
        .handleError((error) {
          print('Error en getUserBooks: $error');
          
          return <DocumentSnapshot>[];
        })
        .map((snapshot) {
          final books = snapshot.docs
              .map((doc) => UserBook.fromFirestore(doc))
              .toList();
          
          
          books.sort((a, b) => b.addedAt.compareTo(a.addedAt));
          return books;
        });
  }

  Stream<List<UserBook>> getFavoriteBooks() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(_userBooksCollection)
        .where('userId', isEqualTo: user.uid)
        .where('isFavorite', isEqualTo: true)
        .snapshots()
        .handleError((error) {
          print('Error en getFavoriteBooks: $error');
          return <DocumentSnapshot>[];
        })
        .map((snapshot) {
          final books = snapshot.docs
              .map((doc) => UserBook.fromFirestore(doc))
              .toList();
          
          
          books.sort((a, b) => b.addedAt.compareTo(a.addedAt));
          return books;
        });
  }

  Future<UserBook?> getUserBookByBookId(String bookId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final querySnapshot = await _firestore
          .collection(_userBooksCollection)
          .where('userId', isEqualTo: user.uid)
          .where('bookId', isEqualTo: bookId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return UserBook.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      
      return null;
    }
  }

  Future<Map<String, int>> getUserStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'total': 0,
          'wantToRead': 0,
          'reading': 0,
          'read': 0,
          'favorites': 0,
        };
      }

      final querySnapshot = await _firestore
          .collection(_userBooksCollection)
          .where('userId', isEqualTo: user.uid)
          .get();

      final userBooks = querySnapshot.docs
          .map((doc) => UserBook.fromFirestore(doc))
          .toList();

      final stats = <String, int>{
        'total': userBooks.length,
        'wantToRead': 0,
        'reading': 0,
        'read': 0,
        'favorites': 0,
      };

      for (final book in userBooks) {
        switch (book.status) {
          case ReadingStatus.wantToRead:
            stats['wantToRead'] = (stats['wantToRead'] ?? 0) + 1;
            break;
          case ReadingStatus.reading:
            stats['reading'] = (stats['reading'] ?? 0) + 1;
            break;
          case ReadingStatus.read:
            stats['read'] = (stats['read'] ?? 0) + 1;
            break;
        }

        if (book.isFavorite) {
          stats['favorites'] = (stats['favorites'] ?? 0) + 1;
        }
      }

      return stats;
    } catch (e) {
      
      return {
        'total': 0,
        'wantToRead': 0,
        'reading': 0,
        'read': 0,
        'favorites': 0,
      };
    }
  }
}