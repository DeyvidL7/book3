import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main/library_screen.dart';
import '../screens/main/my_books_screen.dart';
import '../screens/main/profile_screen.dart';
import 'main_navigation.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String library = '/library';
  static const String myBooks = '/my-books';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainNavigation());
      case library:
        return MaterialPageRoute(builder: (_) => const LibraryScreen());
      case myBooks:
        return MaterialPageRoute(builder: (_) => const MyBooksScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}