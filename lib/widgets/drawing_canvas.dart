import 'package:flutter/material.dart';
import '../models/drawing_stroke.dart';

enum CanvasBackground {
  dark,
  linedDark,
  gridDark,
  staffDark,
  light,
  linedLight,
  gridLight,
  staffLight,
}

class DrawingCanvas extends StatefulWidget {
  final List<DrawingStroke> strokes;
  final bool editable;
  final Function(List<DrawingStroke>)? onStrokesChanged;
  final Color selectedColor;
  final double selectedWidth;
  final bool isEraser;
  final CanvasBackground background;
  final VoidCallback? onUndo;
  final VoidCallback? onDoublePenButton;
  final Function(bool)? onEraserToggled;

  const DrawingCanvas({
    super.key,
    required this.strokes,
    this.editable = true,
    this.onStrokesChanged,
    this.selectedColor = Colors.black,
    this.selectedWidth = 2.0,
    this.isEraser = false,
    this.background = CanvasBackground.dark,
    this.onUndo,
    this.onDoublePenButton,
    this.onEraserToggled,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  late List<DrawingStroke> _strokes;
  DrawingStroke? _currentStroke;
  DateTime? _buttonPressTime;
  DateTime? _lastButtonPressTime;
  bool _eraserActive = false;

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

  Color _getBackgroundColor(CanvasBackground background) {
    switch (background) {
      case CanvasBackground.dark:
      case CanvasBackground.linedDark:
      case CanvasBackground.gridDark:
      case CanvasBackground.staffDark:
        return const Color(0xFF1E1E1E);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        if (event.buttons == 32) {
          final now = DateTime.now();
          if (_lastButtonPressTime != null &&
              now.difference(_lastButtonPressTime!).inMilliseconds < 400) {
            widget.onDoublePenButton?.call();
            _lastButtonPressTime = null;
            _buttonPressTime = null;
            return;
          }
          _lastButtonPressTime = now;
          _buttonPressTime = now;
          return;
        }
        if (!widget.editable) return;
        if (widget.isEraser || _eraserActive) return;
        setState(() {
          _currentStroke = DrawingStroke(
            points: [event.localPosition],
            widths: [widget.selectedWidth],
            color: widget.selectedColor,
            width: widget.selectedWidth,
            isEraser: false,
          );
        });
      },
      onPointerMove: (event) {
        if (event.buttons == 32) {
          if (_buttonPressTime != null && !_eraserActive) {
            final duration = DateTime.now().difference(_buttonPressTime!);
            if (duration.inMilliseconds > 200) {
              setState(() => _eraserActive = true);
              widget.onEraserToggled?.call(true);
            }
          }
          return;
        }
        if (!widget.editable) return;

        // Vektor-Radierer: Strich entfernen wenn Radierer aktiv
        if (widget.isEraser || _eraserActive) {
          final pos = event.localPosition;
          final toRemove = <DrawingStroke>[];
          for (final stroke in _strokes) {
            for (final point in stroke.points) {
              if ((point - pos).distance < 20) {
                toRemove.add(stroke);
                break;
              }
            }
          }
          if (toRemove.isNotEmpty) {
            setState(() => _strokes.removeWhere((s) => toRemove.contains(s)));
            widget.onStrokesChanged?.call(_strokes);
          }
          return;
        }

        final newPoint = event.localPosition;
        final lastPoint = _currentStroke!.points.last;
        final distance = (newPoint - lastPoint).distance;
        final minWidth = widget.selectedWidth * 0.05;
        final maxWidth = widget.selectedWidth;
        final speed = distance.clamp(0.0, 15.0);
        final speedNormalized = (speed / 10.0).clamp(0.0, 1.0);
        final velocityWidth = maxWidth - (speedNormalized * speedNormalized) * (maxWidth - minWidth);
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
      },
      onPointerUp: (event) {
        if (_buttonPressTime != null) {
          final duration = DateTime.now().difference(_buttonPressTime!);
          if (duration.inMilliseconds < 200) {
            widget.onUndo?.call();
          }
          if (_eraserActive) {
            setState(() => _eraserActive = false);
            widget.onEraserToggled?.call(false);
          }
          _buttonPressTime = null;
          return;
        }
        if (!widget.editable || _currentStroke == null) return;
        setState(() {
          _strokes.add(_currentStroke!);
          _currentStroke = null;
        });
        widget.onStrokesChanged?.call(_strokes);
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: _getBackgroundColor(widget.background),
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

  Color _lineColor() {
    switch (background) {
      case CanvasBackground.dark:
      case CanvasBackground.linedDark:
      case CanvasBackground.gridDark:
      case CanvasBackground.staffDark:
        return const Color(0xFF3A3A3A);
      default:
        return const Color(0xFFCCCCCC);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _lineColor()
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    switch (background) {
      case CanvasBackground.dark:
      case CanvasBackground.light:
        break;

      case CanvasBackground.linedDark:
      case CanvasBackground.linedLight:
        const lineSpacing = 28.0;
        for (double y = lineSpacing; y < size.height; y += lineSpacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        break;

      case CanvasBackground.gridDark:
      case CanvasBackground.gridLight:
        const spacing = 28.0;
        for (double y = spacing; y < size.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        for (double x = spacing; x < size.width; x += spacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        break;

      case CanvasBackground.staffDark:
      case CanvasBackground.staffLight:
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

  void _drawStrokeOpaque(Canvas canvas, DrawingStroke stroke) {
    // Wie _drawStroke aber mit voller Opacity — Transparenz kommt vom saveLayer
    final opaqueStroke = DrawingStroke(
      points: stroke.points,
      widths: stroke.widths,
      color: stroke.color.withValues(alpha: 1.0),
      width: stroke.width,
      isEraser: stroke.isEraser,
    );
    _drawStroke(canvas, opaqueStroke);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    for (final stroke in strokes) {
      if (stroke.isEraser || stroke.color.a == 255) {
        _drawStroke(canvas, stroke);
      } else {
        // Highlighter: ganzen Strich auf separatem Layer zeichnen
        final paint = Paint()
          ..color = stroke.color
          ..blendMode = BlendMode.srcOver;
        canvas.saveLayer(null, paint);
        _drawStrokeOpaque(canvas, stroke);
        canvas.restore();
      }
    }
    if (currentStroke != null) {
      if (currentStroke!.color.a == 255) {
        _drawStroke(canvas, currentStroke!);
      } else {
        final paint = Paint()
          ..color = currentStroke!.color
          ..blendMode = BlendMode.srcOver;
        canvas.saveLayer(null, paint);
        _drawStrokeOpaque(canvas, currentStroke!);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_CanvasPainter oldDelegate) => true;
}
