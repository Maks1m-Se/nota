import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'drawing_canvas.dart';

class DrawingToolbar extends StatelessWidget {
  final Color selectedColor;
  final double selectedWidth;
  final bool isEraser;
  final CanvasBackground background;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final Function(Color) onColorChanged;
  final Function(double) onWidthChanged;
  final Function(bool) onEraserToggled;
  final Function(CanvasBackground) onBackgroundChanged;

  const DrawingToolbar({
    super.key,
    required this.selectedColor,
    required this.selectedWidth,
    required this.isEraser,
    required this.background,
    required this.onUndo,
    required this.onClear,
    required this.onColorChanged,
    required this.onWidthChanged,
    required this.onEraserToggled,
    required this.onBackgroundChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Farben
          _ColorButton(color: Colors.black, selected: selectedColor == Colors.black && !isEraser, onTap: () { onEraserToggled(false); onColorChanged(Colors.black); }),
          const SizedBox(width: 6),
          _ColorButton(color: Colors.red, selected: selectedColor == Colors.red && !isEraser, onTap: () { onEraserToggled(false); onColorChanged(Colors.red); }),
          const SizedBox(width: 6),
          _ColorButton(color: Colors.blue, selected: selectedColor == Colors.blue && !isEraser, onTap: () { onEraserToggled(false); onColorChanged(Colors.blue); }),
          const SizedBox(width: 6),
          _ColorButton(color: Colors.green, selected: selectedColor == Colors.green && !isEraser, onTap: () { onEraserToggled(false); onColorChanged(Colors.green); }),
          const SizedBox(width: 6),
          _ColorButton(
            color: Colors.yellow.withValues(alpha: 0.6),
            selected: selectedColor == Colors.yellow.withValues(alpha: 0.6) && !isEraser,
            onTap: () {
              onEraserToggled(false);
              onWidthChanged(16.0);
              onColorChanged(Colors.yellow.withValues(alpha: 0.6));
            },
            label: 'M',
          ),
          const SizedBox(width: 12),
          // Stiftdicke
          _WidthButton(width: 2, selected: selectedWidth == 2 && !isEraser, onTap: () { onEraserToggled(false); onWidthChanged(2); }),
          const SizedBox(width: 6),
          _WidthButton(width: 4, selected: selectedWidth == 4 && !isEraser, onTap: () { onEraserToggled(false); onWidthChanged(4); }),
          const SizedBox(width: 6),
          _WidthButton(width: 8, selected: selectedWidth == 8 && !isEraser, onTap: () { onEraserToggled(false); onWidthChanged(8); }),
          const SizedBox(width: 12),
          // Hintergrund
          PopupMenuButton<CanvasBackground>(
            initialValue: background,
            color: AppTheme.surfaceColor,
            onSelected: onBackgroundChanged,
            tooltip: 'Background',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.textMuted),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.grid_4x4, color: AppTheme.textMuted, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _backgroundLabel(background),
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(value: CanvasBackground.blank, child: Text('Blank')),
              const PopupMenuItem(value: CanvasBackground.lined, child: Text('Lined')),
              const PopupMenuItem(value: CanvasBackground.grid, child: Text('Grid')),
              const PopupMenuItem(value: CanvasBackground.staff, child: Text('Staff lines')),
            ],
          ),
          const Spacer(),
          // Radierer
          IconButton(
            icon: Icon(
              Icons.auto_fix_normal,
              color: isEraser ? AppTheme.primaryColor : AppTheme.textMuted,
              size: 20,
            ),
            onPressed: () => onEraserToggled(!isEraser),
            tooltip: 'Eraser',
          ),
          // Undo
          IconButton(
            icon: const Icon(Icons.undo, color: AppTheme.textMuted, size: 20),
            onPressed: onUndo,
            tooltip: 'Undo',
          ),
          // Clear
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.textMuted, size: 20),
            onPressed: onClear,
            tooltip: 'Clear',
          ),
        ],
      ),
    );
  }

  String _backgroundLabel(CanvasBackground bg) {
    switch (bg) {
      case CanvasBackground.blank: return 'Blank';
      case CanvasBackground.lined: return 'Lined';
      case CanvasBackground.grid: return 'Grid';
      case CanvasBackground.staff: return 'Staff';
    }
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final String? label;

  const _ColorButton({
    required this.color,
    required this.selected,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppTheme.primaryColor : Colors.grey,
            width: 2,
          ),
        ),
        child: label != null
            ? Center(
                child: Text(
                  label!,
                  style: const TextStyle(fontSize: 10, color: Colors.black),
                ),
              )
            : null,
      ),
    );
  }
}

class _WidthButton extends StatelessWidget {
  final double width;
  final bool selected;
  final VoidCallback onTap;

  const _WidthButton({
    required this.width,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppTheme.primaryColor : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Container(
            width: 20,
            height: width.clamp(2, 10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}