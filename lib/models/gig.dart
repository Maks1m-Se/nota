import 'setlist.dart';

class Gig {
  final String id;
  String name;
  String venue;
  DateTime? date;
  List<Setlist> setlists;

  Gig({
    required this.id,
    required this.name,
    this.venue = '',
    this.date,
    List<Setlist>? setlists,
  }) : setlists = setlists ?? [];
}