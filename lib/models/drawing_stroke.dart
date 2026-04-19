import 'dart:ui';

class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double width;
  final bool isEraser;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.width,
    this.isEraser = false,
  });

  Map<String, dynamic> toJson() => {
    'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
    'color': color.toARGB32(),
    'width': width,
    'isEraser': isEraser,
  };

  factory DrawingStroke.fromJson(Map<String, dynamic> json) {
    return DrawingStroke(
      points: (json['points'] as List)
          .map((p) => Offset(p['x'].toDouble(), p['y'].toDouble()))
          .toList(),
      color: Color(json['color']),
      width: json['width'].toDouble(),
      isEraser: json['isEraser'] ?? false,
    );
  }
}