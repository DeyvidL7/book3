import 'package:flutter/material.dart';
import '../../services/user_books_service.dart';
import '../../models/user_book.dart';
import '../../widgets/user_book_card.dart';

class MyBooksScreen extends StatefulWidget {
  const MyBooksScreen({super.key});

  @override
  State<MyBooksScreen> createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends State<MyBooksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserBooksService _userBooksService = UserBooksService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Libros'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Quiero leer'),
            Tab(text: 'Leyendo'),
            Tab(text: 'Leídos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBooksList(null),
          _buildBooksList(ReadingStatus.wantToRead),
          _buildBooksList(ReadingStatus.reading),
          _buildBooksList(ReadingStatus.read),
        ],
      ),
    );
  }

  Widget _buildBooksList(ReadingStatus? status) {
    return StreamBuilder<List<UserBook>>(
      stream: _userBooksService.getUserBooks(status: status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar libros',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final books = snapshot.data ?? [];

        if (books.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.book_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  status == null
                      ? 'No tienes libros aún'
                      : 'No tienes libros en "${_getStatusDisplayName(status)}"',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Busca libros en la biblioteca y añádelos a tu colección',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: books.length,
          itemBuilder: (context, index) {
            return UserBookCard(
              userBook: books[index],
              onStatusChanged: (newStatus) {
                _userBooksService.updateBookStatus(
                  userBookId: books[index].id,
                  status: newStatus,
                );
              },
              onFavoriteToggled: (isFavorite) {
                _userBooksService.toggleFavorite(
                  books[index].id,
                  isFavorite,
                );
              },
              onRemoved: () {
                _userBooksService.removeBookFromLibrary(books[index].id);
              },
            );
          },
        );
      },
    );
  }

  String _getStatusDisplayName(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.wantToRead:
        return 'Quiero leer';
      case ReadingStatus.reading:
        return 'Leyendo';
      case ReadingStatus.read:
        return 'Leídos';
    }
  }
}