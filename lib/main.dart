import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'navigation/app_router.dart';
import 'screens/auth/login_screen.dart';
import 'navigation/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    print('Firebase inicializado correctamente');
  } catch (e) {
    print('Error al inicializar Firebase: $e');
    print('La aplicación funcionará en modo sin conexión');
  }
  
  runApp(MyApp(firebaseEnabled: firebaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool firebaseEnabled;
  
  const MyApp({super.key, this.firebaseEnabled = true});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'BookReview',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        onGenerateRoute: AppRouter.generateRoute,
        home: firebaseEnabled 
          ? StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  return const MainNavigation();
                }
                return const LoginScreen();
              },
            )
          : const MainNavigation(), // Modo sin conexión - ir directo a la navegación principal
      ),
    );
  }
}

