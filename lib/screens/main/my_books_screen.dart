import 'package:book/widgets/books_stats_widget.dart';
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
        title: const Text('Mi Biblioteca'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Theme.of(context).colorScheme.primary,
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(
                  icon: Icon(Icons.dashboard_outlined, size: 20),
                  text: 'Resumen',
                ),
                Tab(
                  icon: Icon(Icons.bookmark_border, size: 20),
                  text: 'Por Leer',
                ),
                Tab(
                  icon: Icon(Icons.auto_stories, size: 20),
                  text: 'Leyendo',
                ),
                Tab(
                  icon: Icon(Icons.done_all, size: 20),
                  text: 'Leídos',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(),
          _buildBooksList(ReadingStatus.wantToRead),
          _buildBooksList(ReadingStatus.reading),
          _buildBooksList(ReadingStatus.read),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          
          const BooksStatsWidget(),

          
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Agregados Recientemente',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          StreamBuilder<List<UserBook>>(
            stream: _userBooksService.getUserBooks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final books = snapshot.data ?? [];
              final recentBooks = books.take(5).toList();

              if (recentBooks.isEmpty) {
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_stories_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '¡Comienza tu aventura de lectura!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Descubre miles de libros y comienza a construir tu biblioteca personal',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          
                          DefaultTabController.of(context)?.animateTo(0);
                        },
                        icon: const Icon(Icons.explore),
                        label: const Text('Explorar Biblioteca'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: recentBooks
                    .map(
                      (book) => UserBookCard(
                        userBook: book,
                        onStatusChanged: (newStatus) {
                          _userBooksService.updateBookStatus(
                            userBookId: book.id,
                            status: newStatus,
                          );
                        },
                        onFavoriteToggled: (isFavorite) {
                          _userBooksService.toggleFavorite(book.id, isFavorite);
                        },
                        onRemoved: () {
                          _userBooksService.removeBookFromLibrary(book.id);
                        },
                      ),
                    )
                    .toList(),
              );
            },
          ),

          
          Container(
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _tabController.animateTo(1); 
              },
              icon: const Icon(Icons.view_list),
              label: const Text('Ver Todos los Libros'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList(ReadingStatus status) {
    return StreamBuilder<List<UserBook>>(
      stream: _userBooksService.getUserBooks(status: status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(status),
                      size: 48,
                      color: _getStatusColor(status),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Sin libros en "${_getStatusDisplayName(status)}"',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Busca libros en la biblioteca y añádelos a tu colección personal',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      
                      
                    },
                    icon: const Icon(Icons.explore),
                    label: const Text('Explorar Biblioteca'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
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
                _userBooksService.toggleFavorite(books[index].id, isFavorite);
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
        return 'Por Leer';
      case ReadingStatus.reading:
        return 'Leyendo';
      case ReadingStatus.read:
        return 'Leídos';
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

  IconData _getStatusIcon(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.wantToRead:
        return Icons.bookmark_border;
      case ReadingStatus.reading:
        return Icons.auto_stories;
      case ReadingStatus.read:
        return Icons.done_all;
    }
  }
}
