import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class NotaApp extends StatelessWidget {
  const NotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nota',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const Scaffold(
        body: Center(
          child: Text(
            'Nota',
            style: TextStyle(
              fontSize: 32,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}