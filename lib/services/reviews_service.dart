import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review.dart';

class ReviewsService {
  late final FirebaseFirestore _firestore;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _reviewsCollection = 'reviews';
  
  // Cache local para las reseñas
  final Map<String, List<Review>> _cachedReviews = {};
  final Map<String, Review> _userReviewsCache = {};
  
  // Stream controllers para cache local
  final Map<String, StreamController<List<Review>>> _streamControllers = {};

  ReviewsService() {
    _firestore = FirebaseFirestore.instance;
    // Configuración más robusta para móvil y web
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

    print('Guardando reseña para libro: $bookId');
    print('Usuario: ${user.uid}');
    print('Rating: $rating');
    print('Datos de reseña: ${review.toFirestore()}');

    final docRef = await _firestore.collection(_reviewsCollection).add(review.toFirestore());
    print('Reseña guardada con ID: ${docRef.id}');
    
    // Actualizar cache local
    final reviewWithId = review.copyWith(id: docRef.id);
    addToLocalCache(reviewWithId);
  }
  
  void addToLocalCache(Review review) {
    // Agregar a cache de reseñas por libro
    if (_cachedReviews.containsKey(review.bookId)) {
      // Verificar si ya existe (evitar duplicados)
      final exists = _cachedReviews[review.bookId]!
          .any((r) => r.id == review.id || (r.userId == review.userId && review.id.isEmpty));
      
      if (!exists) {
        _cachedReviews[review.bookId]!.add(review);
      }
      // Ordenar por fecha
      _cachedReviews[review.bookId]!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      _cachedReviews[review.bookId] = [review];
    }
    
    // Agregar a cache de reseña del usuario
    _userReviewsCache['${review.bookId}_${review.userId}'] = review;
    
    // Notificar al stream
    if (_streamControllers.containsKey(review.bookId)) {
      print('Notificando stream con ${_cachedReviews[review.bookId]!.length} reseñas');
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
    
    // Actualizar cache local - buscar la reseña y actualizarla
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
          
          // Actualizar también en cache de usuario
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
            // Si hay error con orderBy, intentar sin ordenar
            return _firestore
                .collection(_reviewsCollection)
                .where('bookId', isEqualTo: bookId)
                .snapshots();
          })
          .map((snapshot) {
            final reviews = snapshot.docs
                .map((doc) => Review.fromFirestore(doc))
                .toList();
            
            // Ordenar manualmente si es necesario
            reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return reviews;
          });
    } catch (e) {
      print('Error creando stream de reseñas: $e');
      // Fallback: consulta simple sin orderBy
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

      // Primero verificar cache local
      final cacheKey = '${bookId}_${user.uid}';
      if (_userReviewsCache.containsKey(cacheKey)) {
        print('Reseña encontrada en cache local');
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
      _userReviewsCache[cacheKey] = review; // Guardar en cache
      return review;
    } catch (e) {
      print('Error obteniendo reseña de usuario: $e');
      // Si hay error, verificar cache local
      final user = _auth.currentUser;
      if (user != null) {
        final cacheKey = '${bookId}_${user.uid}';
        return _userReviewsCache[cacheKey];
      }
      return null;
    }
  }

  // Método que usa cache local y opcionalmente intenta sincronizar con Firestore
  Stream<List<Review>> getReviewsForBookSimple(String bookId) {
    print('Iniciando stream para libro: $bookId');
    
    // Crear stream controller si no existe
    if (!_streamControllers.containsKey(bookId)) {
      _streamControllers[bookId] = StreamController<List<Review>>.broadcast();
    }
    
    final controller = _streamControllers[bookId]!;
    
    // Emitir cache local inmediatamente
    final cachedReviews = _cachedReviews[bookId] ?? [];
    print('Emitiendo cache local: ${cachedReviews.length} reseñas');
    controller.add(cachedReviews);
    
    // Intentar cargar de Firestore en background
    _loadFromFirestoreBackground(bookId);
    
    return controller.stream;
  }
  
  void _loadFromFirestoreBackground(String bookId) async {
    try {
      print('Intentando cargar de Firestore para libro: $bookId');
      final querySnapshot = await _firestore
          .collection(_reviewsCollection)
          .where('bookId', isEqualTo: bookId)
          .get()
          .timeout(const Duration(seconds: 5));
      
      final reviews = querySnapshot.docs.map((doc) {
        print('Documento encontrado: ${doc.id}');
        return Review.fromFirestore(doc);
      }).toList();
      
      // Ordenar por fecha
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      print('Cargadas ${reviews.length} reseñas de Firestore');
      
      // Actualizar cache
      _cachedReviews[bookId] = reviews;
      
      // Emitir al stream
      if (_streamControllers.containsKey(bookId)) {
        _streamControllers[bookId]!.add(reviews);
      }
    } catch (e) {
      print('Error cargando de Firestore: $e');
      // No hacer nada - mantener cache local
    }
  }
  
  // Método que retorna solo cache local
  List<Review> getCachedReviewsForBook(String bookId) {
    return _cachedReviews[bookId] ?? [];
  }
  
  // Método de debug para verificar todas las reseñas en Firestore
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
      // Si la colección no existe, retornar valores por defecto
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      };
    }
  }
}