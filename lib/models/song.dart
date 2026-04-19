import 'drawing_stroke.dart';

class Song {
  final String id;
  String title;
  String artist;
  String key;
  int? bpm;
  String notes;
  String abbreviation;
  List<DrawingStroke> strokes;
  List<DrawingStroke> quickStrokes;

  Song({
    required this.id,
    required this.title,
    this.artist = '',
    this.key = '',
    this.bpm,
    this.notes = '',
    this.abbreviation = '',
    List<DrawingStroke>? strokes,
    List<DrawingStroke>? quickStrokes,
  }) : strokes = strokes ?? [],
       quickStrokes = quickStrokes ?? [];
}