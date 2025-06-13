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
      ), // Reducido de 8 a 6
      elevation: 1, // Reducido de 2 a 1
      shadowColor: colorScheme.shadow.withOpacity(0.05), // Reducido opacidad
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Reducido de 16 a 12
        side: BorderSide(
          color: isUserReview
              ? colorScheme.primary.withOpacity(0.15) // Reducido opacidad
              : Colors.transparent,
          width: 0.5, // Reducido de 1 a 0.5
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // Reducido de 20 a 12
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header compacto con usuario y acciones
            Row(
              children: [
                // Avatar más pequeño
                Container(
                  width: 32, // Reducido de 48 a 32
                  height: 32, // Reducido de 48 a 32
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      16,
                    ), // Reducido de 24 a 16
                  ),
                  child: Center(
                    child: Text(
                      _getUserInitials(review.userEmail),
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 12, // Reducido de 18 a 12
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Reducido de 16 a 10
                // Información del usuario compacta
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
                                // Cambiado de titleMedium a titleSmall
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                                fontSize: 13, // Añadido tamaño específico
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUserReview) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6, // Reducido de 8 a 6
                                vertical: 2, // Reducido de 4 a 2
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(
                                  8,
                                ), // Reducido de 12 a 8
                              ),
                              child: Text(
                                'Tu reseña',
                                style: TextStyle(
                                  fontSize: 9, // Reducido de 11 a 9
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2), // Reducido de 4 a 2
                      Row(
                        children: [
                          RatingStars(
                            rating: review.rating.toDouble(),
                            size: 14, // Reducido de 18 a 14
                          ),
                          const SizedBox(width: 6), // Reducido de 8 a 6
                          Text(
                            _formatDate(review.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11, // Añadido tamaño específico
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Menú de acciones más compacto
                if (isUserReview && (onEdit != null || onDelete != null))
                  SizedBox(
                    width: 32, // Tamaño fijo más pequeño
                    height: 32,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.more_vert,
                        color: colorScheme.onSurfaceVariant,
                        size: 16, // Reducido de 20 a 16
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // Reducido de 12 a 8
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
                            height: 36, // Reducido altura
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: colorScheme.primary,
                                ), // Reducido de 20 a 16
                                const SizedBox(width: 8), // Reducido de 12 a 8
                                const Text(
                                  'Editar',
                                  style: TextStyle(fontSize: 13),
                                ), // Reducido tamaño
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          PopupMenuItem(
                            value: 'delete',
                            height: 36, // Reducido altura
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  size: 16,
                                  color: colorScheme.error,
                                ), // Reducido de 20 a 16
                                const SizedBox(width: 8), // Reducido de 12 a 8
                                const Text(
                                  'Eliminar',
                                  style: TextStyle(fontSize: 13),
                                ), // Reducido tamaño
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),

            // Comentario de la reseña más compacto
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 8), // Reducido de 16 a 8
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10), // Reducido de 16 a 10
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(
                    0.2,
                  ), // Reducido opacidad
                  borderRadius: BorderRadius.circular(8), // Reducido de 12 a 8
                ),
                child: Text(
                  review.comment!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    // Cambiado de bodyLarge a bodyMedium
                    height: 1.3, // Reducido de 1.5 a 1.3
                    color: colorScheme.onSurface,
                    fontSize: 13, // Añadido tamaño específico
                  ),
                  maxLines: 3, // Limitar líneas para mantener compacto
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            // Indicador de edición más compacto
            if (review.updatedAt != review.createdAt) ...[
              const SizedBox(height: 6), // Reducido de 12 a 6
              Row(
                children: [
                  Icon(
                    Icons.edit,
                    size: 10, // Reducido de 14 a 10
                    color: colorScheme.onSurfaceVariant.withOpacity(
                      0.6,
                    ), // Reducido opacidad
                  ),
                  const SizedBox(width: 3), // Reducido de 4 a 3
                  Text(
                    'Editado ${_formatDate(review.updatedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(
                        0.7,
                      ), // Reducido opacidad
                      fontStyle: FontStyle.italic,
                      fontSize: 10, // Añadido tamaño específico
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
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');

    return formattedName.isNotEmpty ? formattedName : 'Usuario';
  }
}
