import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/review.dart';
import '../services/reviews_service.dart';
import '../widgets/rating_stars.dart';

class AddReviewScreen extends StatefulWidget {
  final Book book;
  final Review? existingReview;

  const AddReviewScreen({
    super.key,
    required this.book,
    this.existingReview,
  });

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final ReviewsService _reviewsService = ReviewsService();
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _commentController.text = widget.existingReview!.comment ?? '';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _saveReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una calificación')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.existingReview != null) {
        await _reviewsService.updateReview(
          reviewId: widget.existingReview!.id,
          rating: _rating,
          comment: _commentController.text.trim().isEmpty 
              ? null 
              : _commentController.text.trim(),
        );
      } else {
        await _reviewsService.addReview(
          bookId: widget.book.id,
          rating: _rating,
          comment: _commentController.text.trim().isEmpty 
              ? null 
              : _commentController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar reseña: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteReview() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reseña'),
        content: const Text('¿Estás seguro de que quieres eliminar esta reseña?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _reviewsService.deleteReview(widget.existingReview!.id);
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar reseña: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingReview != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Reseña' : 'Añadir Reseña'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (isEditing)
            IconButton(
              onPressed: _isLoading ? null : _deleteReview,
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[300],
                      ),
                      child: const Icon(
                        Icons.book,
                        color: Colors.grey,
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.book.author,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Calificación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: RatingStars(
                rating: _rating.toDouble(),
                size: 40,
                interactive: true,
                onRatingChanged: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Comentario (opcional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Escribe tu opinión sobre este libro...',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveReview,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(isEditing ? 'Actualizar Reseña' : 'Publicar Reseña'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}