import 'song_slot.dart';

class Setlist {
  final String id;
  String name;
  List<SongSlot> slots;

  Setlist({
    required this.id,
    required this.name,
    List<SongSlot>? slots,
  }) : slots = slots ?? [];
}