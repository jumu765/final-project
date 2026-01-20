import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobilee_shop/screens/login_screen.dart';
import 'package:mobilee_shop/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wpulcqamexniaoqrtirf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndwdWxjcWFtZXhuaWFvcXJ0aXJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2ODMxNTEsImV4cCI6MjA4MzI1OTE1MX0.5qzlxMTq7L8kN8ClelGjXi147dj-JCZP-O3utTydluE',
  );

  runApp(const MobileShopApp());
}

class MobileShopApp extends StatelessWidget {
  const MobileShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Shop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 183, 58, 169)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
