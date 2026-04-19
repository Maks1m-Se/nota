import 'setlist.dart';

class Gig {
  final String id;
  String name;
  String venue;
  DateTime? date;
  String time;
  String soundcheckTime;
  bool isOutdoor;
  String fee;
  String organizer;
  String notes;
  List<Setlist> setlists;

  Gig({
    required this.id,
    required this.name,
    this.venue = '',
    this.date,
    this.time = '',
    this.soundcheckTime = '',
    this.isOutdoor = false,
    this.fee = '',
    this.organizer = '',
    this.notes = '',
    List<Setlist>? setlists,
  }) : setlists = setlists ?? [];
}