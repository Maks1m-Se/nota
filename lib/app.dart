import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/bands/band_list_screen.dart';
import 'providers/band_provider.dart';

class NotaApp extends StatelessWidget {
  const NotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BandProvider(),
      child: MaterialApp(
        title: 'Nota',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const BandListScreen(),
      ),
    );
  }
}