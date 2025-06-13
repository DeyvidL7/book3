import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_book.dart';

class UserBookCard extends StatelessWidget {
  final UserBook userBook;
  final Function(ReadingStatus)? onStatusChanged;
  final Function(bool)? onFavoriteToggled;
  final VoidCallback? onRemoved;
  final VoidCallback? onTap;

  const UserBookCard({
    super.key,
    required this.userBook,
    this.onStatusChanged,
    this.onFavoriteToggled,
    this.onRemoved,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 90,
                  child: userBook.bookCoverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: userBook.bookCoverUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.book,
                              color: Colors.grey,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.book,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.book,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userBook.bookTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userBook.bookAuthor,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: userBook.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: userBook.statusColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            userBook.statusDisplayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: userBook.statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (userBook.isFavorite) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.favorite,
                            size: 16,
                            color: Colors.red[400],
                          ),
                        ],
                        if (userBook.userRating != null) ...[
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                userBook.userRating.toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Añadido ${_formatDate(userBook.addedAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'changeStatus',
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz),
                        SizedBox(width: 8),
                        Text('Cambiar estado'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggleFavorite',
                    child: Row(
                      children: [
                        Icon(userBook.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border),
                        const SizedBox(width: 8),
                        Text(userBook.isFavorite
                            ? 'Quitar de favoritos'
                            : 'Añadir a favoritos'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'changeStatus':
        _showStatusDialog(context);
        break;
      case 'toggleFavorite':
        onFavoriteToggled?.call(!userBook.isFavorite);
        break;
      case 'remove':
        _showRemoveDialog(context);
        break;
    }
  }

  void _showStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ReadingStatus.values.map((status) {
            return RadioListTile<ReadingStatus>(
              value: status,
              groupValue: userBook.status,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  onStatusChanged?.call(value);
                }
              },
              title: Text(status.name == 'wantToRead'
                  ? 'Quiero leer'
                  : status.name == 'reading'
                      ? 'Leyendo'
                      : 'Leído'),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${userBook.bookTitle}" de tu biblioteca?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRemoved?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} horas';
    } else {
      return 'hoy';
    }
  }
}