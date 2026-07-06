import 'dart:async';
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
        home: const _SplashGate(),
      ),
    );
  }
}

/// Flutter-seitiger Splash: zeigt das Nota-Lockup groß, dann Fade ins
/// Dashboard. Umgeht das Android-12+-Limit (System-Splash-Icon ist auf
/// ein kleines, OS-fixiertes Fenster begrenzt).
class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  static const _splashAsset = 'assets/images/nota_splash_tight.png';
  // Eingebackener Bild-Hintergrund — Scaffold muss exakt matchen,
  // sonst zeichnet sich das Bild als Rechteck ab.
  static const _splashBackground = Color(0xFF0E0E11);

  bool _showApp = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showApp = true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Vorab decodieren, damit das Logo im ersten Frame steht statt aufzuploppen.
    precacheImage(const AssetImage(_splashAsset), context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _showApp
          ? const BandListScreen()
          : const Scaffold(
              backgroundColor: _splashBackground,
              body: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.55,
                  child: Image(image: AssetImage(_splashAsset)),
                ),
              ),
            ),
    );
  }
}