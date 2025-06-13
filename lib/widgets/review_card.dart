import 'package:flutter/material.dart';
import '../models/review.dart';
import 'rating_stars.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final bool isUserReview;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    this.isUserReview = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isUserReview 
              ? colorScheme.primary.withOpacity(0.2)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con usuario y acciones
            Row(
              children: [
                // Avatar del usuario
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      _getUserInitials(review.userEmail),
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Información del usuario
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getUserDisplayName(review.userEmail),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUserReview) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Tu reseña',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          RatingStars(
                            rating: review.rating.toDouble(),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(review.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Menú de acciones para reseña del usuario
                if (isUserReview && (onEdit != null || onDelete != null))
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!();
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                    },
                    itemBuilder: (context) => [
                      if (onEdit != null)
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20, color: colorScheme.primary),
                              const SizedBox(width: 12),
                              const Text('Editar'),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: colorScheme.error),
                              const SizedBox(width: 12),
                              const Text('Eliminar'),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            
            // Comentario de la reseña
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  review.comment!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
            
            // Indicador de edición
            if (review.updatedAt != review.createdAt) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.edit,
                    size: 14,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Editado ${_formatDate(review.updatedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return 'hace ${weeks} semana${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'hace un momento';
    }
  }

  String _getUserInitials(String email) {
    if (email.isEmpty) return 'U';
    
    final namePart = email.split('@').first;
    if (namePart.length >= 2) {
      return namePart.substring(0, 2).toUpperCase();
    }
    return namePart[0].toUpperCase();
  }

  String _getUserDisplayName(String email) {
    if (email.isEmpty) return 'Usuario anónimo';
    
    final namePart = email.split('@').first;
    // Convertir nombres como "juan.perez" o "juan_perez" a "Juan Perez"
    final formattedName = namePart
        .replaceAll(RegExp(r'[._]'), ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
    
    return formattedName.isNotEmpty ? formattedName : 'Usuario';
  }
}