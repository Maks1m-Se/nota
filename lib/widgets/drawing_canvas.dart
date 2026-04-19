import 'package:flutter/material.dart';
import '../models/drawing_stroke.dart';

class DrawingCanvas extends StatefulWidget {
  final List<DrawingStroke> strokes;
  final bool editable;
  final Function(List<DrawingStroke>)? onStrokesChanged;
  final Color selectedColor;
  final double selectedWidth;
  final bool isEraser;

  const DrawingCanvas({
    super.key,
    required this.strokes,
    this.editable = true,
    this.onStrokesChanged,
    this.selectedColor = Colors.white,
    this.selectedWidth = 2.0,
    this.isEraser = false,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  late List<DrawingStroke> _strokes;
  DrawingStroke? _currentStroke;

  @override
  void initState() {
    super.initState();
    _strokes = List.from(widget.strokes);
  }

  @override
  void didUpdateWidget(DrawingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.strokes != widget.strokes) {
      _strokes = List.from(widget.strokes);
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.editable) return;
    setState(() {
      _currentStroke = DrawingStroke(
        points: [details.localPosition],
        color: widget.isEraser ? Colors.transparent : widget.selectedColor,
        width: widget.selectedWidth,
        isEraser: widget.isEraser,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.editable || _currentStroke == null) return;
    setState(() {
      _currentStroke = DrawingStroke(
        points: [..._currentStroke!.points, details.localPosition],
        color: _currentStroke!.color,
        width: _currentStroke!.width,
        isEraser: _currentStroke!.isEraser,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.editable || _currentStroke == null) return;
    setState(() {
      _strokes.add(_currentStroke!);
      _currentStroke = null;
    });
    widget.onStrokesChanged?.call(_strokes);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: ClipRect(
        child: CustomPaint(
          painter: _CanvasPainter(
            strokes: _strokes,
            currentStroke: _currentStroke,
          ),
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;

  _CanvasPainter({required this.strokes, this.currentStroke});

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.isEraser) {
      paint.blendMode = BlendMode.clear;
      paint.color = Colors.transparent;
    } else {
      paint.color = stroke.color;
    }

    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  @override
  bool shouldRepaint(_CanvasPainter oldDelegate) => true;
}