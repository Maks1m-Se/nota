import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

/// Chord-Chart-PNGs als Files im App-Documents-Verzeichnis (charts/).
/// Der Prefs-Blob referenziert nur noch Dateinamen — Pfad wird hier
/// zur Laufzeit aufgelöst (Documents-Pfad kann sich zwischen Installs ändern).
class ChartStorage {
  static Future<Directory> _chartsDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/charts');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Schreibt das Chart und gibt den Dateinamen zurück (nur Filename).
  /// Timestamp im Namen: bei Neuimport entsteht ein neuer Name, damit
  /// UI-Vergleiche (didUpdateWidget) den Wechsel erkennen — das alte
  /// File räumt der Provider über deleteChart ab.
  static Future<String> saveChart(String songId, Uint8List bytes) async {
    final dir = await _chartsDir();
    final fileName = '${songId}_${DateTime.now().millisecondsSinceEpoch}.png';
    await File('${dir.path}/$fileName').writeAsBytes(bytes, flush: true);
    return fileName;
  }

  /// Fehler-tolerant: fehlendes/defektes File → null, kein Crash.
  static Future<Uint8List?> loadChart(String fileName) async {
    try {
      final dir = await _chartsDir();
      final file = File('${dir.path}/$fileName');
      if (!await file.exists()) return null;
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  static Future<void> deleteChart(String fileName) async {
    try {
      final dir = await _chartsDir();
      final file = File('${dir.path}/$fileName');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Lösch-Fehler ist unkritisch (Orphan-File), niemals crashen.
    }
  }
}
