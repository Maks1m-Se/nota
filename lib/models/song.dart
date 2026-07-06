import 'drawing_stroke.dart';
import '../widgets/drawing_canvas.dart';

class Song {
  final String id;
  String title;
  String artist;
  String key;
  int? bpm;
  String notes;
  String abbreviation;
  String intro;
  String outro;
  bool hasSolo;
  bool hasBacking;
  List<DrawingStroke> strokes;
  CanvasBackground canvasBackground;

  /// Chart liegt als PNG-File in charts/ (siehe ChartStorage), hier nur Filename.
  String? chordChartFile;

  /// Nur noch Migrations-Träger für alte Blobs/Backups — wird in
  /// BandProvider._load() zu chordChartFile extrahiert und dann genullt.
  String? chordChartBase64;
  double chordChartX;
  double chordChartY;
  double chordChartScale;

  Song({
    required this.id,
    required this.title,
    this.artist = '',
    this.key = '',
    this.bpm,
    this.notes = '',
    this.abbreviation = '',
    this.intro = '',
    this.outro = '',
    this.hasSolo = false,
    this.hasBacking = false,
    this.canvasBackground = CanvasBackground.dark,
    this.chordChartFile,
    this.chordChartBase64,
    this.chordChartX = 0.0,
    this.chordChartY = 0.0,
    this.chordChartScale = 1.0,
    List<DrawingStroke>? strokes,
  }) : strokes = strokes ?? [];
}
