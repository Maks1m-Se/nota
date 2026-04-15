import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/bands/band_list_screen.dart';

class NotaApp extends StatelessWidget {
  const NotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nota',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const BandListScreen(),
    );
  }
}