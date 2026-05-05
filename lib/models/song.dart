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
  List<DrawingStroke> quickStrokes;
  CanvasBackground canvasBackground;
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
    this.chordChartBase64,
    this.chordChartX = 0.0,
    this.chordChartY = 0.0,
    this.chordChartScale = 1.0,
    List<DrawingStroke>? strokes,
    List<DrawingStroke>? quickStrokes,
  }) : strokes = strokes ?? [],
       quickStrokes = quickStrokes ?? [];
}