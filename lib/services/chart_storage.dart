import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;
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

  /// Kopiert ein Chart für einen anderen Song (Songs zwischen Bands kopieren).
  /// Neuer Name nach saveChart-Schema — Kopie hat eine eigene Datei, damit
  /// deleteChart am Original die Kopie nie mitreißt.
  /// Fehler-tolerant: fehlende Quelle oder Schreibfehler → null, kein Crash.
  static Future<String?> copyChart(String fromFileName, String toSongId) async {
    String? fileName;
    try {
      final dir = await _chartsDir();
      final source = File('${dir.path}/$fromFileName');
      if (!await source.exists()) return null;
      fileName = '${toSongId}_${DateTime.now().millisecondsSinceEpoch}.png';
      await source.copy('${dir.path}/$fileName');
      return fileName;
    } catch (e) {
      debugPrint('ChartStorage.copyChart failed ($fromFileName → $toSongId): $e');
      // Halb geschriebene Kopie abräumen — sonst Orphan-PNG in charts/.
      if (fileName != null) await deleteChart(fileName);
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
