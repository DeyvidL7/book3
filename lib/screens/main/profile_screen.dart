import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_books_service.dart';
import '../../navigation/app_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserBooksService _userBooksService = UserBooksService();
  Map<String, int>? _userStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    try {
      final stats = await _userBooksService.getUserStats();
      setState(() {
        _userStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRouter.login);
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        user?.email?.isNotEmpty == true 
                            ? user!.email![0].toUpperCase() 
                            : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.email ?? 'Usuario',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Miembro desde: ${_formatDate(user?.metadata.creationTime)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Estadísticas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (_userStats != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Total', _userStats!['total'].toString()),
                            _buildStatItem('Leídos', _userStats!['read'].toString()),
                            _buildStatItem('Favoritos', _userStats!['favorites'].toString()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Quiero leer', _userStats!['wantToRead'].toString()),
                            _buildStatItem('Leyendo', _userStats!['reading'].toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              const Text(
                'Mis Favoritos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder(
                stream: _userBooksService.getFavoriteBooks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }

                  final favoriteBooks = snapshot.data ?? [];

                  if (favoriteBooks.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No tienes libros favoritos aún',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ...favoriteBooks.take(3).map((book) => ListTile(
                            leading: const Icon(Icons.favorite, color: Colors.red),
                            title: Text(
                              book.bookTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(book.bookAuthor),
                          )),
                          if (favoriteBooks.length > 3)
                            TextButton(
                              onPressed: () {
                                // Navigate to favorites screen
                              },
                              child: Text('Ver todos (${favoriteBooks.length})'),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Configuración',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cambiar foto de perfil'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Implementar cambio de foto
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notificaciones'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Implementar configuración de notificaciones
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Ayuda y soporte'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Implementar ayuda
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Fecha desconocida';
    return '${date.day}/${date.month}/${date.year}';
  }
}