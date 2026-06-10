import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authService = AuthService();
  final token = await authService.getToken();
  final initialRoute = token != null ? '/home' : '/login';

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
      ],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JardimJá Cliente',
      theme: ThemeData(
        primaryColor: const Color(0xFF2D6A2D),
        scaffoldBackgroundColor: const Color(0xFFF1F8F1),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6A2D),
          primary: const Color(0xFF2D6A2D),
          secondary: const Color(0xFF81C784),
        ),
        textTheme: GoogleFonts.nunitoTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D6A2D),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D6A2D),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2D6A2D), width: 2),
          ),
        ),
      ),
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/login':
            page = LoginScreen();
            break;
          case '/home':
            page = HomeScreen();
            break;
          default:
            page = LoginScreen();
        }
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
