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

  /// Sentinel für nullable Felder: unterscheidet "nicht übergeben" von
  /// "explizit null" — z.B. chordChartFile: null, wenn copyChart fehlschlägt.
  /// Sonst würde die Kopie auf das Chart-File des Originals zeigen.
  static const Object _unset = Object();

  /// Alle Felder optional. Neues Feld am Modell = auch hier ergänzen.
  /// strokes: Liste wird immer neu angelegt (DrawingStroke ist immutable,
  /// die Liste nicht) — Original und Kopie teilen nie dieselbe Liste.
  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? key,
    Object? bpm = _unset,
    String? notes,
    String? abbreviation,
    String? intro,
    String? outro,
    bool? hasSolo,
    bool? hasBacking,
    List<DrawingStroke>? strokes,
    CanvasBackground? canvasBackground,
    Object? chordChartFile = _unset,
    Object? chordChartBase64 = _unset,
    double? chordChartX,
    double? chordChartY,
    double? chordChartScale,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      key: key ?? this.key,
      bpm: identical(bpm, _unset) ? this.bpm : bpm as int?,
      notes: notes ?? this.notes,
      abbreviation: abbreviation ?? this.abbreviation,
      intro: intro ?? this.intro,
      outro: outro ?? this.outro,
      hasSolo: hasSolo ?? this.hasSolo,
      hasBacking: hasBacking ?? this.hasBacking,
      strokes: List<DrawingStroke>.of(strokes ?? this.strokes),
      canvasBackground: canvasBackground ?? this.canvasBackground,
      chordChartFile: identical(chordChartFile, _unset)
          ? this.chordChartFile
          : chordChartFile as String?,
      chordChartBase64: identical(chordChartBase64, _unset)
          ? this.chordChartBase64
          : chordChartBase64 as String?,
      chordChartX: chordChartX ?? this.chordChartX,
      chordChartY: chordChartY ?? this.chordChartY,
      chordChartScale: chordChartScale ?? this.chordChartScale,
    );
  }
}
