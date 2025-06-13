import 'package:book/models/book.dart';
import 'package:book/models/user_book.dart';
import 'package:book/services/user_books_service.dart';
import 'package:flutter/material.dart';

class AddBookDialog extends StatefulWidget {
  final Book book;
  final UserBook? existingUserBook; 

  const AddBookDialog({super.key, required this.book, this.existingUserBook});

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  final UserBooksService _userBooksService = UserBooksService();
  ReadingStatus _selectedStatus = ReadingStatus.wantToRead;
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingUserBook != null) {
      _selectedStatus = widget.existingUserBook!.status;
      _isFavorite = widget.existingUserBook!.isFavorite;
    }
  }

  Future<void> _saveBook() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.existingUserBook != null) {
        
        await _userBooksService.updateBookStatus(
          userBookId: widget.existingUserBook!.id,
          status: _selectedStatus,
        );

        if (_isFavorite != widget.existingUserBook!.isFavorite) {
          await _userBooksService.toggleFavorite(
            widget.existingUserBook!.id,
            _isFavorite,
          );
        }
      } else {
        
        await _userBooksService.addBookToLibrary(
          book: widget.book,
          status: _selectedStatus,
          isFavorite: _isFavorite,
        );
      }

      if (mounted) {
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
    final isEditing = widget.existingUserBook != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            isEditing ? Icons.edit : Icons.add,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isEditing ? 'Editar en Mi Biblioteca' : 'Agregar a Mi Biblioteca',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.book, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.book.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.book.author,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            
            const Text(
              'Estado de lectura:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),

            ...ReadingStatus.values.map(
              (status) => RadioListTile<ReadingStatus>(
                value: status,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
                title: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_getStatusDisplayName(status)),
                  ],
                ),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),

            const SizedBox(height: 16),

            
            SwitchListTile(
              value: _isFavorite,
              onChanged: (value) {
                setState(() {
                  _isFavorite = value;
                });
              },
              title: const Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Marcar como favorito'),
                ],
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveBook,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Actualizar' : 'Agregar'),
        ),
      ],
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

  Color _getStatusColor(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.wantToRead:
        return const Color(0xFF2196F3); 
      case ReadingStatus.reading:
        return const Color(0xFFFF9800); 
      case ReadingStatus.read:
        return const Color(0xFF4CAF50); 
    }
  }
}
