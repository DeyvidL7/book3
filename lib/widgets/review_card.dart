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
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ), 
      elevation: 1, 
      shadowColor: colorScheme.shadow.withOpacity(0.05), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), 
        side: BorderSide(
          color: isUserReview
              ? colorScheme.primary.withOpacity(0.15) 
              : Colors.transparent,
          width: 0.5, 
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              children: [
                
                Container(
                  width: 32, 
                  height: 32, 
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      16,
                    ), 
                  ),
                  child: Center(
                    child: Text(
                      _getUserInitials(review.userEmail),
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 12, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10), 
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getUserDisplayName(review.userEmail),
                              style: theme.textTheme.titleSmall?.copyWith(
                                
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                                fontSize: 13, 
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUserReview) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6, 
                                vertical: 2, 
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(
                                  8,
                                ), 
                              ),
                              child: Text(
                                'Tu reseña',
                                style: TextStyle(
                                  fontSize: 9, 
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2), 
                      Row(
                        children: [
                          RatingStars(
                            rating: review.rating.toDouble(),
                            size: 14, 
                          ),
                          const SizedBox(width: 6), 
                          Text(
                            _formatDate(review.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11, 
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                
                if (isUserReview && (onEdit != null || onDelete != null))
                  SizedBox(
                    width: 32, 
                    height: 32,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.more_vert,
                        color: colorScheme.onSurfaceVariant,
                        size: 16, 
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ), 
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
                            height: 36, 
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: colorScheme.primary,
                                ), 
                                const SizedBox(width: 8), 
                                const Text(
                                  'Editar',
                                  style: TextStyle(fontSize: 13),
                                ), 
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          PopupMenuItem(
                            value: 'delete',
                            height: 36, 
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  size: 16,
                                  color: colorScheme.error,
                                ), 
                                const SizedBox(width: 8), 
                                const Text(
                                  'Eliminar',
                                  style: TextStyle(fontSize: 13),
                                ), 
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),

            
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 8), 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10), 
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(
                    0.2,
                  ), 
                  borderRadius: BorderRadius.circular(8), 
                ),
                child: Text(
                  review.comment!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    
                    height: 1.3, 
                    color: colorScheme.onSurface,
                    fontSize: 13, 
                  ),
                  maxLines: 3, 
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            
            if (review.updatedAt != review.createdAt) ...[
              const SizedBox(height: 6), 
              Row(
                children: [
                  Icon(
                    Icons.edit,
                    size: 10, 
                    color: colorScheme.onSurfaceVariant.withOpacity(
                      0.6,
                    ), 
                  ),
                  const SizedBox(width: 3), 
                  Text(
                    'Editado ${_formatDate(review.updatedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(
                        0.7,
                      ), 
                      fontStyle: FontStyle.italic,
                      fontSize: 10, 
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
    
    final formattedName = namePart
        .replaceAll(RegExp(r'[._]'), ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');

    return formattedName.isNotEmpty ? formattedName : 'Usuario';
  }
}
