import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review.dart';

class ReviewsService {
  late final FirebaseFirestore _firestore;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _reviewsCollection = 'reviews';
  
  
  final Map<String, List<Review>> _cachedReviews = {};
  final Map<String, Review> _userReviewsCache = {};
  
  
  final Map<String, StreamController<List<Review>>> _streamControllers = {};

  ReviewsService() {
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

  Future<void> addReview({
    required String bookId,
    required int rating,
    String? comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final now = DateTime.now();
    final review = Review(
      id: '',
      bookId: bookId,
      userId: user.uid,
      userEmail: user.email ?? '',
      rating: rating,
      comment: comment,
      createdAt: now,
      updatedAt: now,
    );

    final docRef = await _firestore.collection(_reviewsCollection).add(review.toFirestore());
    
    
    final reviewWithId = review.copyWith(id: docRef.id);
    addToLocalCache(reviewWithId);
  }
  
  void addToLocalCache(Review review) {
    
    if (_cachedReviews.containsKey(review.bookId)) {
      
      final exists = _cachedReviews[review.bookId]!
          .any((r) => r.id == review.id || (r.userId == review.userId && review.id.isEmpty));
      
      if (!exists) {
        _cachedReviews[review.bookId]!.add(review);
      }
      
      _cachedReviews[review.bookId]!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      _cachedReviews[review.bookId] = [review];
    }
    
    
    _userReviewsCache['${review.bookId}_${review.userId}'] = review;
    
    
    if (_streamControllers.containsKey(review.bookId)) {
      _streamControllers[review.bookId]!.add(_cachedReviews[review.bookId]!);
    }
  }

  Future<void> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _firestore.collection(_reviewsCollection).doc(reviewId).update({
      'rating': rating,
      'comment': comment,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
    
    
    for (final bookId in _cachedReviews.keys) {
      final reviews = _cachedReviews[bookId]!;
      for (int i = 0; i < reviews.length; i++) {
        if (reviews[i].id == reviewId) {
          final updatedReview = reviews[i].copyWith(
            rating: rating,
            comment: comment,
            updatedAt: DateTime.now(),
          );
          reviews[i] = updatedReview;
          
          
          final cacheKey = '${bookId}_${user.uid}';
          _userReviewsCache[cacheKey] = updatedReview;
          break;
        }
      }
    }
  }

  Future<void> deleteReview(String reviewId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _firestore.collection(_reviewsCollection).doc(reviewId).delete();
  }

  Stream<List<Review>> getReviewsForBook(String bookId) {
    try {
      return _firestore
          .collection(_reviewsCollection)
          .where('bookId', isEqualTo: bookId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((error) {
            print('Error en stream de reseñas: $error');
            
            return _firestore
                .collection(_reviewsCollection)
                .where('bookId', isEqualTo: bookId)
                .snapshots();
          })
          .map((snapshot) {
            final reviews = snapshot.docs
                .map((doc) => Review.fromFirestore(doc))
                .toList();
            
            
            reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return reviews;
          });
    } catch (e) {
      print('Error creando stream de reseñas: $e');
      
      return _firestore
          .collection(_reviewsCollection)
          .where('bookId', isEqualTo: bookId)
          .snapshots()
          .map((snapshot) {
            final reviews = snapshot.docs
                .map((doc) => Review.fromFirestore(doc))
                .toList();
            reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return reviews;
          });
    }
  }

  Stream<List<Review>> getUserReviews() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    try {
      return _firestore
          .collection(_reviewsCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((error) {
            print('Error en stream de reseñas de usuario: $error');
            return _firestore
                .collection(_reviewsCollection)
                .where('userId', isEqualTo: user.uid)
                .snapshots();
          })
          .map((snapshot) {
            final reviews = snapshot.docs
                .map((doc) => Review.fromFirestore(doc))
                .toList();
            reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return reviews;
          });
    } catch (e) {
      print('Error creando stream de reseñas de usuario: $e');
      return _firestore
          .collection(_reviewsCollection)
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) {
            final reviews = snapshot.docs
                .map((doc) => Review.fromFirestore(doc))
                .toList();
            reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return reviews;
          });
    }
  }

  Future<Review?> getUserReviewForBook(String bookId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      
      final cacheKey = '${bookId}_${user.uid}';
      if (_userReviewsCache.containsKey(cacheKey)) {
        return _userReviewsCache[cacheKey];
      }

      final querySnapshot = await _firestore
          .collection(_reviewsCollection)
          .where('bookId', isEqualTo: bookId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final review = Review.fromFirestore(querySnapshot.docs.first);
      _userReviewsCache[cacheKey] = review; 
      return review;
    } catch (e) {
      
      final user = _auth.currentUser;
      if (user != null) {
        final cacheKey = '${bookId}_${user.uid}';
        return _userReviewsCache[cacheKey];
      }
      return null;
    }
  }

  
  Stream<List<Review>> getReviewsForBookSimple(String bookId) {
    
    if (!_streamControllers.containsKey(bookId)) {
      _streamControllers[bookId] = StreamController<List<Review>>.broadcast();
    }
    
    final controller = _streamControllers[bookId]!;
    
    
    final cachedReviews = _cachedReviews[bookId] ?? [];
    controller.add(cachedReviews);
    
    
    _loadFromFirestoreBackground(bookId);
    
    return controller.stream;
  }
  
  void _loadFromFirestoreBackground(String bookId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_reviewsCollection)
          .where('bookId', isEqualTo: bookId)
          .get()
          .timeout(const Duration(seconds: 5));
      
      final reviews = querySnapshot.docs.map((doc) {
        return Review.fromFirestore(doc);
      }).toList();
      
      
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      
      _cachedReviews[bookId] = reviews;
      
      
      if (_streamControllers.containsKey(bookId)) {
        _streamControllers[bookId]!.add(reviews);
      }
    } catch (e) {
      
    }
  }
  
  
  List<Review> getCachedReviewsForBook(String bookId) {
    return _cachedReviews[bookId] ?? [];
  }
  
  
  Future<void> debugAllReviews() async {
    try {
      print('=== DEBUG: Verificando todas las reseñas en Firestore ===');
      final snapshot = await _firestore.collection(_reviewsCollection).get();
      print('Total documentos en colección reviews: ${snapshot.docs.length}');
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        print('Doc ID: ${doc.id}');
        print('  bookId: ${data['bookId']}');
        print('  userId: ${data['userId']}');
        print('  userEmail: ${data['userEmail']}');
        print('  rating: ${data['rating']}');
        print('  comment: ${data['comment']}');
        print('  createdAt: ${data['createdAt']}');
        print('---');
      }
      print('=== END DEBUG ===');
    } catch (e) {
      print('Error en debug: $e');
    }
  }

  Future<Map<String, dynamic>> getBookStatistics(String bookId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_reviewsCollection)
          .where('bookId', isEqualTo: bookId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalReviews': 0,
          'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
      }

      final reviews = querySnapshot.docs
          .map((doc) => Review.fromFirestore(doc))
          .toList();

      final totalReviews = reviews.length;
      final totalRating = reviews.fold(0, (sum, review) => sum + review.rating);
      final averageRating = totalRating / totalReviews;

      final ratingDistribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (final review in reviews) {
        ratingDistribution[review.rating] = 
            (ratingDistribution[review.rating] ?? 0) + 1;
      }

      return {
        'averageRating': averageRating,
        'totalReviews': totalReviews,
        'ratingDistribution': ratingDistribution,
      };
    } catch (e) {
      
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      };
    }
  }
}