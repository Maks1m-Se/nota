class Song {
  final String id;
  String title;
  String artist;
  String key;
  int? bpm;
  String notes;

  Song({
    required this.id,
    required this.title,
    this.artist = '',
    this.key = '',
    this.bpm,
    this.notes = '',
  });
}