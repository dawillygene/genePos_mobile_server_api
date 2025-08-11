import 'package:flutter/material.dart';
import 'package:gene_pos/constants.dart';
import 'package:gene_pos/database_helper.dart';
import 'package:gene_pos/services/auth_service.dart';
import 'package:gene_pos/screens/splash_screen.dart';
import 'package:gene_pos/screens/dashboard_screen.dart';
import 'package:gene_pos/screens/login_screen.dart';
import 'package:gene_pos/screens/register_screen.dart';
import 'package:gene_pos/screens/units_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  await AuthService().checkLoginStatus();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GenePOS',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
        useMaterial3: true,
      ),
      initialRoute: AuthService().isAuthenticated ? '/dashboard' : '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/units': (context) => UnitsScreen(),
      },
    );
  }
}
