import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';
import '../models/user_book.dart';
import '../services/user_books_service.dart';
import '../screens/dialog/add_book_dialog.dart';

class CompactGridBookCard extends StatefulWidget {
  final Book book;
  final VoidCallback? onTap;
  final bool showQuickActions;

  const CompactGridBookCard({
    super.key,
    required this.book,
    this.onTap,
    this.showQuickActions = true,
  });

  @override
  State<CompactGridBookCard> createState() => _CompactGridBookCardState();
}

class _CompactGridBookCardState extends State<CompactGridBookCard>
    with SingleTickerProviderStateMixin {
  final UserBooksService _userBooksService = UserBooksService();
  UserBook? _userBook;
  bool _isLoading = false;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heartAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    if (widget.showQuickActions && FirebaseAuth.instance.currentUser != null) {
      _checkUserBook();
    }
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
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

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    
    _heartAnimationController.forward().then((_) {
      _heartAnimationController.reverse();
    });

    setState(() {
      _isLoading = true;
    });

    try {
      if (_userBook == null) {
        
        await _userBooksService.addBookToLibrary(
          book: widget.book,
          status: ReadingStatus.wantToRead,
          isFavorite: true,
        );
        await _checkUserBook();
      } else {
        
        await _userBooksService.toggleFavorite(
          _userBook!.id,
          !_userBook!.isFavorite,
        );
        setState(() {
          _userBook = _userBook!.copyWith(isFavorite: !_userBook!.isFavorite);
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _userBook?.isFavorite == true
                  ? '❤️ Agregado a favoritos'
                  : '💔 Eliminado de favoritos',
            ),
            duration: const Duration(seconds: 1),
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
      elevation: 1,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: widget.onTap,
        onDoubleTap:
            widget.showQuickActions && FirebaseAuth.instance.currentUser != null
            ? _toggleFavorite
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Expanded(
                flex: 7,
                child: Stack(
                  children: [
                    
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: AspectRatio(
                          aspectRatio: 2 / 3,
                          child: widget.book.coverUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: widget.book.coverUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.book,
                                      size: 24,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.book,
                                          size: 24,
                                          color: Colors.grey,
                                        ),
                                      ),
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.book,
                                    size: 24,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    
                    if (widget.showQuickActions &&
                        FirebaseAuth.instance.currentUser != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _toggleFavorite,
                          child: AnimatedBuilder(
                            animation: _heartAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _heartAnimation.value,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _userBook?.isFavorite == true
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 16,
                                    color: _userBook?.isFavorite == true
                                        ? Colors.red
                                        : Colors.grey[600],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Text(
                      widget.book.title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    
                    Text(
                      widget.book.author,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[600],
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    
                    Row(
                      children: [
                        
                        if (widget.book.averageRating != null) ...[
                          Icon(Icons.star, size: 10, color: Colors.amber[700]),
                          const SizedBox(width: 2),
                          Text(
                            widget.book.averageRating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 8),
                          ),
                        ],

                        const Spacer(),

                        
                        if (widget.showQuickActions &&
                            FirebaseAuth.instance.currentUser != null)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                  )
                                : PopupMenuButton<String>(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.more_vert,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    iconSize: 14,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    position: PopupMenuPosition.under,
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'wantToRead':
                                          _quickAddToLibrary(
                                            ReadingStatus.wantToRead,
                                          );
                                          break;
                                        case 'reading':
                                          _quickAddToLibrary(
                                            ReadingStatus.reading,
                                          );
                                          break;
                                        case 'read':
                                          _quickAddToLibrary(
                                            ReadingStatus.read,
                                          );
                                          break;
                                        case 'details':
                                          _showDetailedDialog();
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'wantToRead',
                                        height: 32,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2196F3),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Quiero leer',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            if (_userBook?.status ==
                                                ReadingStatus.wantToRead) ...[
                                              const Spacer(),
                                              const Icon(
                                                Icons.check,
                                                size: 14,
                                                color: Color(0xFF2196F3),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'reading',
                                        height: 32,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFF9800),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Leyendo',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            if (_userBook?.status ==
                                                ReadingStatus.reading) ...[
                                              const Spacer(),
                                              const Icon(
                                                Icons.check,
                                                size: 14,
                                                color: Color(0xFFFF9800),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'read',
                                        height: 32,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF4CAF50),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Leído',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            if (_userBook?.status ==
                                                ReadingStatus.read) ...[
                                              const Spacer(),
                                              const Icon(
                                                Icons.check,
                                                size: 14,
                                                color: Color(0xFF4CAF50),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const PopupMenuDivider(),
                                      PopupMenuItem(
                                        value: 'details',
                                        height: 32,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.settings,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Más opciones',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                      ],
                    ),
                  ],
                ),
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
