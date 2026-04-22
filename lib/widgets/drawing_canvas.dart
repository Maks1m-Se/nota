import 'package:flutter/material.dart';
import '../models/drawing_stroke.dart';

enum CanvasBackground { blank, lined, grid, staff }

class DrawingCanvas extends StatefulWidget {
  final List<DrawingStroke> strokes;
  final bool editable;
  final Function(List<DrawingStroke>)? onStrokesChanged;
  final Color selectedColor;
  final double selectedWidth;
  final bool isEraser;
  final CanvasBackground background;

  const DrawingCanvas({
    super.key,
    required this.strokes,
    this.editable = true,
    this.onStrokesChanged,
    this.selectedColor = Colors.black,
    this.selectedWidth = 2.0,
    this.isEraser = false,
    this.background = CanvasBackground.blank,
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
        widths: [widget.selectedWidth],
        color: widget.isEraser ? const Color(0xFFF5F5F5) : widget.selectedColor,
        width: widget.selectedWidth,
        isEraser: widget.isEraser,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.editable || _currentStroke == null) return;
    
    final newPoint = details.localPosition;
    final lastPoint = _currentStroke!.points.last;
    final distance = (newPoint - lastPoint).distance;
    
    final minWidth = widget.selectedWidth * 0.05;
    final maxWidth = widget.selectedWidth;
    final speed = distance.clamp(0.0, 15.0);
    final speedNormalized = (speed / 10.0).clamp(0.0, 1.0);
    final velocityWidth = maxWidth - (speedNormalized * speedNormalized) * (maxWidth - minWidth);
    
    // Smooth: mix with last width
    final lastWidth = _currentStroke!.widths.isNotEmpty
        ? _currentStroke!.widths.last
        : widget.selectedWidth;
    final smoothWidth = lastWidth * 0.92 + velocityWidth * 0.08;

    setState(() {
      _currentStroke = DrawingStroke(
        points: [..._currentStroke!.points, newPoint],
        widths: [..._currentStroke!.widths, smoothWidth],
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
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF5F5F5),
        child: CustomPaint(
          painter: _CanvasPainter(
            strokes: _strokes,
            currentStroke: _currentStroke,
            background: widget.background,
          ),
        ),
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;
  final CanvasBackground background;

  _CanvasPainter({
    required this.strokes,
    this.currentStroke,
    required this.background,
  });

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    switch (background) {
      case CanvasBackground.blank:
        break;

      case CanvasBackground.lined:
        const lineSpacing = 28.0;
        for (double y = lineSpacing; y < size.height; y += lineSpacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        break;

      case CanvasBackground.grid:
        const spacing = 28.0;
        for (double y = spacing; y < size.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        for (double x = spacing; x < size.width; x += spacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        break;

      case CanvasBackground.staff:
        const staffSpacing = 48.0;
        const lineCount = 5;
        const lineSpacing = 8.0;
        double y = staffSpacing;
        while (y < size.height - staffSpacing) {
          for (int i = 0; i < lineCount; i++) {
            final lineY = y + i * lineSpacing;
            canvas.drawLine(Offset(0, lineY), Offset(size.width, lineY), paint);
          }
          y += staffSpacing + lineCount * lineSpacing;
        }
        break;
    }
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;
    if (stroke.points.length == 1) {
      final paint = Paint()
        ..color = stroke.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(stroke.points.first, stroke.width / 2, paint);
      return;
    }

    for (int i = 0; i < stroke.points.length - 1; i++) {
      final p0 = stroke.points[i];
      final p1 = stroke.points[i + 1];
      final w = stroke.widths.isNotEmpty && i < stroke.widths.length
          ? stroke.widths[i]
          : stroke.width;

      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(p0, p1, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
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
