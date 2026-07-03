import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/bands/band_list_screen.dart';
import 'providers/band_provider.dart';

class NotaApp extends StatefulWidget {
  const NotaApp({super.key});

  @override
  State<NotaApp> createState() => _NotaAppState();
}

class _NotaAppState extends State<NotaApp> with WidgetsBindingObserver {
  final BandProvider _provider = BandProvider();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _provider.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Hintergrund / Schließen → pending Strokes sofort auf Disk.
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _provider.flushPendingSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BandProvider>.value(
      value: _provider,
      child: MaterialApp(
        title: 'Nota',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const BandListScreen(),
      ),
    );
  }
}