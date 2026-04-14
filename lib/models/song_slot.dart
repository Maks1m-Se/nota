class SongSlot {
  final String id;
  final String songId;
  String? keyOverride;
  String? notesOverride;
  int order;

  SongSlot({
    required this.id,
    required this.songId,
    this.keyOverride,
    this.notesOverride,
    required this.order,
  });
}