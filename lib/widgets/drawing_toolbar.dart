import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DrawingToolbar extends StatelessWidget {
  final Color selectedColor;
  final double selectedWidth;
  final bool isEraser;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final Function(Color) onColorChanged;
  final Function(double) onWidthChanged;
  final Function(bool) onEraserToggled;

  const DrawingToolbar({
    super.key,
    required this.selectedColor,
    required this.selectedWidth,
    required this.isEraser,
    required this.onUndo,
    required this.onClear,
    required this.onColorChanged,
    required this.onWidthChanged,
    required this.onEraserToggled,
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
          _ColorButton(color: Colors.white, selected: selectedColor == Colors.white && !isEraser, onTap: () { onEraserToggled(false); onColorChanged(Colors.white); }),
          const SizedBox(width: 6),
          _ColorButton(color: Colors.red, selected: selectedColor == Colors.red && !isEraser, onTap: () { onEraserToggled(false); onColorChanged(Colors.red); }),
          const SizedBox(width: 6),
          _ColorButton(color: Colors.blue, selected: selectedColor == Colors.blue && !isEraser, onTap: () { onEraserToggled(false); onColorChanged(Colors.blue); }),
          const SizedBox(width: 6),
          _ColorButton(color: Colors.yellow, selected: selectedColor == Colors.yellow && !isEraser, onTap: () { onEraserToggled(false); onColorChanged(Colors.yellow); }),
          const SizedBox(width: 6),
          // Marker (gelb transparent)
          _ColorButton(
            color: Colors.yellow.withValues(alpha: 0.4),
            selected: selectedColor == Colors.yellow.withValues(alpha: 0.4) && !isEraser,
            onTap: () {
              onEraserToggled(false);
              onWidthChanged(16.0);
              onColorChanged(Colors.yellow.withValues(alpha: 0.4));
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
          const Spacer(),
          // Radierer
          IconButton(
            icon: Icon(
              Icons.auto_fix_high,
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
            color: selected ? Colors.white : Colors.transparent,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}