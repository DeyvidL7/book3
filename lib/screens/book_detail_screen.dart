import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';
import '../models/review.dart';
import '../services/reviews_service.dart';
import '../widgets/rating_stars.dart';
import '../widgets/review_card.dart';
import 'add_review_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final ReviewsService _reviewsService = ReviewsService();
  Review? _userReview;
  Map<String, dynamic>? _bookStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookData();
  }

  Future<void> _loadBookData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Usar timeout para evitar esperas infinitas
      await Future.any([
        _loadFirestoreData(),
        Future.delayed(const Duration(seconds: 8), () => throw Exception('Timeout')),
      ]);
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() {
        _isLoading = false;
        _userReview = null;
        _bookStats = {
          'averageRating': widget.book.averageRating ?? 0.0,
          'totalReviews': widget.book.ratingsCount ?? 0,
          'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
      });
    }
  }

  Future<void> _loadFirestoreData() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        final userReview = await _reviewsService.getUserReviewForBook(widget.book.id);
        final bookStats = await _reviewsService.getBookStatistics(widget.book.id);
        
        setState(() {
          _userReview = userReview;
          _bookStats = bookStats;
          _isLoading = false;
        });
      } else {
        setState(() {
          _userReview = null;
          _bookStats = {
            'averageRating': widget.book.averageRating ?? 0.0,
            'totalReviews': widget.book.ratingsCount ?? 0,
            'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando datos de Firestore: $e');
      setState(() {
        _userReview = null;
        _bookStats = {
          'averageRating': widget.book.averageRating ?? 0.0,
          'totalReviews': widget.book.ratingsCount ?? 0,
          'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
        _isLoading = false;
      });
    }
  }

  void _navigateToAddReview() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReviewScreen(
          book: widget.book,
          existingReview: _userReview,
        ),
      ),
    );

    if (result == true) {
      _loadBookData();
    }
  }

  Future<void> _deleteReview(Review review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reseña'),
        content: const Text('¿Estás seguro de que quieres eliminar tu reseña?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _reviewsService.deleteReview(review.id);
      _loadBookData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reseña eliminada correctamente'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar reseña: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Libro'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implementar agregar a favoritos
            },
            icon: const Icon(Icons.favorite_border),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookHeader(),
            const SizedBox(height: 24),
            _buildBookInfo(),
            const SizedBox(height: 24),
            if (widget.book.description != null) ...[
              _buildDescription(),
              const SizedBox(height: 24),
            ],
            _buildRatingSection(),
            const SizedBox(height: 24),
            _buildReviewsSection(),
          ],
        ),
      ),
      floatingActionButton: FirebaseAuth.instance.currentUser != null
          ? FloatingActionButton.extended(
              onPressed: _navigateToAddReview,
              icon: Icon(_userReview != null ? Icons.edit : Icons.add),
              label: Text(_userReview != null ? 'Editar Reseña' : 'Añadir Reseña'),
            )
          : null,
    );
  }

  Widget _buildBookHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 120,
            height: 180,
            child: widget.book.coverUrl != null
                ? CachedNetworkImage(
                    imageUrl: widget.book.coverUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.book,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.book,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.book,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.book.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.book.author,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              if (_bookStats != null && !_isLoading) ...[
                Row(
                  children: [
                    RatingStars(
                      rating: _bookStats!['averageRating']?.toDouble() ?? 0.0,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(_bookStats!['averageRating'] ?? 0.0).toStringAsFixed(1)} (${_bookStats!['totalReviews']} reseñas)',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ] else if (_isLoading) ...[
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.book.publishedYear != null)
              _buildInfoRow('Año de publicación', widget.book.publishedYear.toString()),
            if (widget.book.isbn != null)
              _buildInfoRow('ISBN', widget.book.isbn!),
            if (widget.book.categories.isNotEmpty)
              _buildInfoRow('Categorías', widget.book.categories.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.book.description!,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    if (_isLoading || _bookStats == null) {
      return const SizedBox.shrink();
    }

    final ratingDistribution = _bookStats!['ratingDistribution'] as Map<int, int>;
    final totalReviews = _bookStats!['totalReviews'] as int;

    if (totalReviews == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calificaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            for (int i = 5; i >= 1; i--)
              _buildRatingBar(i, ratingDistribution[i] ?? 0, totalReviews),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(int rating, int count, int total) {
    final percentage = total > 0 ? count / total : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$rating'),
          const SizedBox(width: 8),
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reseñas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Review>>(
          stream: _reviewsService.getReviewsForBook(widget.book.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar reseñas',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Intenta nuevamente más tarde',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            final reviews = snapshot.data ?? [];

            if (reviews.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No hay reseñas aún.\n¡Sé el primero en escribir una!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: reviews.map((review) {
                final currentUser = FirebaseAuth.instance.currentUser;
                final isUserReview = currentUser != null && review.userId == currentUser.uid;
                
                return ReviewCard(
                  review: review,
                  isUserReview: isUserReview,
                  onEdit: isUserReview ? () => _navigateToAddReview() : null,
                  onDelete: isUserReview ? () => _deleteReview(review) : null,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}