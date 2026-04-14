class Band {
  final String id;
  String name;
  String genre;

  Band({
    required this.id,
    required this.name,
    this.genre = '',
  });
}