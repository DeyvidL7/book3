import 'package:book/screens/dialog/add_book_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';
import '../models/user_book.dart';
import '../services/user_books_service.dart';

class BookCard extends StatefulWidget {
  final Book book;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showQuickActions;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.trailing,
    this.showQuickActions = true,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  final UserBooksService _userBooksService = UserBooksService();
  UserBook? _userBook;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.showQuickActions && FirebaseAuth.instance.currentUser != null) {
      _checkUserBook();
    }
  }

  Future<void> _checkUserBook() async {
    try {
      final userBook = await _userBooksService.getUserBookByBookId(
        widget.book.id,
      );
      if (mounted) {
        setState(() {
          _userBook = userBook;
        });
      }
    } catch (e) {
    }
  }

  Future<void> _quickAddToLibrary(ReadingStatus status) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_userBook != null) {
        await _userBooksService.updateBookStatus(
          userBookId: _userBook!.id,
          status: status,
        );
        setState(() {
          _userBook = _userBook!.copyWith(status: status);
        });
      } else {
        await _userBooksService.addBookToLibrary(
          book: widget.book,
          status: status,
        );
        await _checkUserBook();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _userBook == null
                  ? 'Libro agregado a ${_getStatusDisplayName(status)}'
                  : 'Libro movido a ${_getStatusDisplayName(status)}',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
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

  void _showDetailedDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AddBookDialog(book: widget.book, existingUserBook: _userBook),
    );

    if (result == true) {
      await _checkUserBook();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          InkWell(
            onTap: widget.onTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                      child: widget.book.coverUrl != null
                          ? CachedNetworkImage(
                              imageUrl: widget.book.coverUrl!,
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
                              child: const Icon(Icons.book, color: Colors.grey),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.book.title,
                          style: const TextStyle(
                            fontSize: 16,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        if (_userBook != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _userBook!.statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _userBook!.statusColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _userBook!.statusColor,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _userBook!.statusDisplayName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _userBook!.statusColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_userBook!.isFavorite) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.favorite,
                                    size: 12,
                                    color: Colors.red[400],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        if (widget.book.description != null) ...[
                          Text(
                            widget.book.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                        ],

                        Row(
                          children: [
                            if (widget.book.averageRating != null) ...[
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.book.averageRating!.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (widget.book.publishedYear != null) ...[
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.book.publishedYear.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.trailing != null) widget.trailing!,
                ],
              ),
            ),
          ),

          if (widget.showQuickActions &&
              FirebaseAuth.instance.currentUser != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickActionButton(
                          icon: Icons.bookmark_add,
                          label: 'Quiero leer',
                          color: const Color(0xFF2196F3),
                          onPressed: () =>
                              _quickAddToLibrary(ReadingStatus.wantToRead),
                          isActive:
                              _userBook?.status == ReadingStatus.wantToRead,
                        ),
                        _buildQuickActionButton(
                          icon: Icons.menu_book,
                          label: 'Leyendo',
                          color: const Color(0xFFFF9800),
                          onPressed: () =>
                              _quickAddToLibrary(ReadingStatus.reading),
                          isActive: _userBook?.status == ReadingStatus.reading,
                        ),
                        _buildQuickActionButton(
                          icon: Icons.done,
                          label: 'Leído',
                          color: const Color(0xFF4CAF50),
                          onPressed: () =>
                              _quickAddToLibrary(ReadingStatus.read),
                          isActive: _userBook?.status == ReadingStatus.read,
                        ),
                        _buildQuickActionButton(
                          icon: Icons.more_horiz,
                          label: 'Más',
                          color: Colors.grey[600]!,
                          onPressed: _showDetailedDialog,
                          isActive: false,
                        ),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(8),
            border: isActive ? Border.all(color: color.withOpacity(0.3)) : null,
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isActive ? color : Colors.grey[600]),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? color : Colors.grey[600],
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusDisplayName(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.wantToRead:
        return 'Quiero leer';
      case ReadingStatus.reading:
        return 'Leyendo';
      case ReadingStatus.read:
        return 'Leído';
    }
  }
}
