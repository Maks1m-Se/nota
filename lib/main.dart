import 'package:flutter/material.dart';

void main() {
  runApp(const NotaApp());
}

class NotaApp extends StatelessWidget {
  const NotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nota',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF141414),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFC8A96E),
          surface: Color(0xFF1A1A1A),
        ),
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Nota',
            style: TextStyle(
              fontSize: 32,
              color: Color(0xFFC8A96E),
            ),
          ),
        ),
      ),
    );
  }
}