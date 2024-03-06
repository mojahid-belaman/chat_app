import 'package:chat_app/screens/auth.dart';
import 'package:flutter/material.dart';

final theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 63, 17, 177)));

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: theme,
      home: const AuthScreen(),
    );
  }
}
