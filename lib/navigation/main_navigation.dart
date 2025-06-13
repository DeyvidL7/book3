import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/main/library_screen.dart';
import '../screens/main/my_books_screen.dart';
import '../screens/main/profile_screen.dart';
import '../services/user_books_service.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final UserBooksService _userBooksService = UserBooksService();
  int _myBooksCount = 0;

  final List<Widget> _screens = [
    const LibraryScreen(),
    const MyBooksScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadBooksCount();
  }

  Future<void> _loadBooksCount() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        final stats = await _userBooksService.getUserStats();
        if (mounted) {
          setState(() {
            _myBooksCount = stats['total'] ?? 0;
          });
        }
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            _loadBooksCount();
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Biblioteca',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.book),
                if (_myBooksCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _myBooksCount > 99 ? '99+' : _myBooksCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Mis Libros',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
