import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../theme/app_theme.dart';
import 'drawing_canvas.dart';

enum DrawingTool { pen, highlighter, eraser }

class DrawingToolbar extends StatefulWidget {
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
  final bool chordChartEditMode;
  final VoidCallback? onLoadPdf;
  final VoidCallback? onToggleChordChartEdit;
  final VoidCallback? onRemoveChordChart;
  final bool hasChordChart;

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
    this.chordChartEditMode = false,
    this.onLoadPdf,
    this.onToggleChordChartEdit,
    this.onRemoveChordChart,
    this.hasChordChart = false,
  });

  @override
  State<DrawingToolbar> createState() => _DrawingToolbarState();
}

class _DrawingToolbarState extends State<DrawingToolbar> {
  DrawingTool _activeTool = DrawingTool.pen;

  // Per-tool settings
  double _penWidth = 4.0;
  Color _penColor = Colors.black;
  double _highlighterWidth = 48.0;
  Color _highlighterColor = Colors.yellow;
  double _highlighterOpacity = 0.4;

  static const List<Color> _paletteColors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
  ];

  void _selectTool(DrawingTool tool) {
    setState(() => _activeTool = tool);
    if (tool == DrawingTool.eraser) {
      widget.onEraserToggled(true);
    } else {
      widget.onEraserToggled(false);
      if (tool == DrawingTool.pen) {
        widget.onColorChanged(_penColor);
        widget.onWidthChanged(_penWidth);
      } else if (tool == DrawingTool.highlighter) {
        widget.onColorChanged(_highlighterColor.withValues(alpha: _highlighterOpacity));
        widget.onWidthChanged(_highlighterWidth);
      }
    }
  }

  void _selectColor(Color color) {
    if (_activeTool == DrawingTool.pen) {
      setState(() => _penColor = color);
      widget.onColorChanged(color);
    } else if (_activeTool == DrawingTool.highlighter) {
      setState(() => _highlighterColor = color);
      widget.onColorChanged(color.withValues(alpha: _highlighterOpacity));
    }
  }

  void _selectWidth(double width) {
    if (_activeTool == DrawingTool.pen) {
      setState(() => _penWidth = width);
    } else if (_activeTool == DrawingTool.highlighter) {
      setState(() => _highlighterWidth = width);
    }
    widget.onWidthChanged(width);
  }

  void _showColorPicker() {
    final currentColor = _activeTool == DrawingTool.pen ? _penColor : _highlighterColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Pick a color', style: TextStyle(color: AppTheme.textPrimary)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: _selectColor,
            enableAlpha: false,
            labelTypes: const [],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showHighlighterSettings() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: const Text('Highlighter Settings', style: TextStyle(color: AppTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Opacity', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              Slider(
                value: _highlighterOpacity,
                min: 0.05,
                max: 0.8,
                activeColor: AppTheme.primaryColor,
                onChanged: (v) {
                  setDialogState(() => _highlighterOpacity = v);
                  setState(() => _highlighterOpacity = v);
                  widget.onColorChanged(_highlighterColor.withValues(alpha: v));
                },
              ),
              const SizedBox(height: 8),
              const Text('Width', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              Slider(
                value: _highlighterWidth,
                min: 8.0,
                max: 120.0,
                activeColor: AppTheme.primaryColor,
                onChanged: (v) {
                  setDialogState(() => _highlighterWidth = v);
                  setState(() => _highlighterWidth = v);
                  widget.onWidthChanged(v);
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWidthSlider() {
    final currentWidth = _activeTool == DrawingTool.pen ? _penWidth : _highlighterWidth;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: const Text('Stroke Width', style: TextStyle(color: AppTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview
              Container(
                height: 60,
                width: double.infinity,
                color: AppTheme.backgroundColor,
                child: Center(
                  child: Container(
                    width: 100,
                    height: currentWidth.clamp(1.0, 40.0),
                    decoration: BoxDecoration(
                      color: _activeTool == DrawingTool.pen ? _penColor : _highlighterColor,
                      borderRadius: BorderRadius.circular(currentWidth),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Slider(
                value: currentWidth,
                min: 1.0,
                max: _activeTool == DrawingTool.pen ? 20.0 : 120.0,
                activeColor: AppTheme.primaryColor,
                onChanged: (v) {
                  setDialogState(() {});
                  _selectWidth(v);
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Tools
          _ToolButton(
            icon: Icons.edit,
            label: 'Pen',
            selected: _activeTool == DrawingTool.pen,
            onTap: () => _selectTool(DrawingTool.pen),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _selectTool(DrawingTool.highlighter),
            onLongPress: _showHighlighterSettings,
            child: _ToolButton(
              icon: Icons.border_color,
              label: 'Marker',
              selected: _activeTool == DrawingTool.highlighter,
              onTap: () => _selectTool(DrawingTool.highlighter),
            ),
          ),
          const SizedBox(width: 4),
          _ToolButton(
            icon: Icons.auto_fix_normal,
            label: 'Eraser',
            selected: _activeTool == DrawingTool.eraser,
            onTap: () => _selectTool(DrawingTool.eraser),
          ),
          const SizedBox(width: 12),

          // Farben — nur sichtbar wenn nicht Eraser
          if (_activeTool != DrawingTool.eraser) ...[
            ..._paletteColors.map((color) => Padding(
              padding: const EdgeInsets.only(right: 5),
              child: _ColorButton(
                color: color,
                selected: (_activeTool == DrawingTool.pen ? _penColor : _highlighterColor) == color,
                onTap: () => _selectColor(color),
              ),
            )),
            // Custom Color Picker
            GestureDetector(
              onTap: _showColorPicker,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.textMuted, width: 1.5),
                  gradient: const SweepGradient(colors: [
                    Colors.red, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.red
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Dicke Buttons mit Long Press für Slider
          if (_activeTool == DrawingTool.pen) ...[
            GestureDetector(
              onTap: () => _selectWidth(2.0),
              onLongPress: _showWidthSlider,
              child: _WidthDot(size: 6, selected: _penWidth == 2.0),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _selectWidth(4.0),
              onLongPress: _showWidthSlider,
              child: _WidthDot(size: 10, selected: _penWidth == 4.0),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _selectWidth(8.0),
              onLongPress: _showWidthSlider,
              child: _WidthDot(size: 15, selected: _penWidth == 8.0),
            ),
            const SizedBox(width: 12),
          ] else if (_activeTool == DrawingTool.highlighter) ...[
              GestureDetector(
                onTap: () => _selectWidth(12.0),
                onLongPress: _showWidthSlider,
                child: _WidthDot(size: 6, selected: _highlighterWidth == 12.0),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _selectWidth(24.0),
                onLongPress: _showWidthSlider,
                child: _WidthDot(size: 10, selected: _highlighterWidth == 24.0),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _selectWidth(48.0),
                onLongPress: _showWidthSlider,
                child: _WidthDot(size: 15, selected: _highlighterWidth == 48.0),
              ),
              const SizedBox(width: 12),
            ],

          // Hintergrund
          PopupMenuButton<CanvasBackground>(
            initialValue: widget.background,
            color: AppTheme.surfaceColor,
            onSelected: widget.onBackgroundChanged,
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
                    _backgroundLabel(widget.background),
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(value: CanvasBackground.dark, child: Text('Dark')),
              const PopupMenuItem(value: CanvasBackground.linedDark, child: Text('Lined Dark')),
              const PopupMenuItem(value: CanvasBackground.gridDark, child: Text('Grid Dark')),
              const PopupMenuItem(value: CanvasBackground.staffDark, child: Text('Staff Dark')),
              const PopupMenuItem(value: CanvasBackground.light, child: Text('Light')),
              const PopupMenuItem(value: CanvasBackground.linedLight, child: Text('Lined Light')),
              const PopupMenuItem(value: CanvasBackground.gridLight, child: Text('Grid Light')),
              const PopupMenuItem(value: CanvasBackground.staffLight, child: Text('Staff Light')),
            ],
          ),

          const Spacer(),

          // Chord Chart Buttons
          if (widget.hasChordChart) ...[
            IconButton(
              icon: Icon(
                Icons.open_with,
                color: widget.chordChartEditMode ? AppTheme.primaryColor : AppTheme.textMuted,
                size: 20,
              ),
              onPressed: widget.onToggleChordChartEdit,
              tooltip: 'Move/Scale Chart',
            ),
            IconButton(
              icon: const Icon(Icons.image_not_supported_outlined, color: Colors.red, size: 20),
              onPressed: widget.onRemoveChordChart,
              tooltip: 'Remove Chart',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppTheme.textMuted, size: 20),
            onPressed: widget.onLoadPdf,
            tooltip: 'Load PDF',
          ),

          // Undo + Clear
          IconButton(
            icon: const Icon(Icons.undo, color: AppTheme.textMuted, size: 20),
            onPressed: widget.onUndo,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.textMuted, size: 20),
            onPressed: widget.onClear,
            tooltip: 'Clear',
          ),
        ],
      ),
    );
  }

  String _backgroundLabel(CanvasBackground bg) {
    switch (bg) {
      case CanvasBackground.dark: return 'Dark';
      case CanvasBackground.linedDark: return 'Lined D';
      case CanvasBackground.gridDark: return 'Grid D';
      case CanvasBackground.staffDark: return 'Staff D';
      case CanvasBackground.light: return 'Light';
      case CanvasBackground.linedLight: return 'Lined L';
      case CanvasBackground.gridLight: return 'Grid L';
      case CanvasBackground.staffLight: return 'Staff L';
    }
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? AppTheme.primaryColor : Colors.transparent,
          ),
        ),
        child: Icon(icon, color: selected ? AppTheme.primaryColor : AppTheme.textMuted, size: 18),
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorButton({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : Colors.grey.withValues(alpha: 0.5),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? [BoxShadow(color: AppTheme.primaryColor, blurRadius: 4, spreadRadius: 1)] : null,
        ),
      ),
    );
  }
}

class _WidthDot extends StatelessWidget {
  final double size;
  final bool selected;

  const _WidthDot({required this.size, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : AppTheme.textMuted,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}