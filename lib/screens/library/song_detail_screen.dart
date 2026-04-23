import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song.dart';
import '../../models/drawing_stroke.dart';
import '../../providers/band_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/drawing_canvas.dart';
import '../../widgets/drawing_toolbar.dart';
import '../live/live_screen.dart';
import '../../models/setlist.dart';
import '../../models/song_slot.dart';

class SongDetailScreen extends StatefulWidget {
  final Song song;
  final String bandId;

  const SongDetailScreen({
    super.key,
    required this.song,
    required this.bandId,
  });

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  bool _metaExpanded = false;

  // Drawing state
  Color _selectedColor = Colors.black;
  double _selectedWidth = 2.0;
  bool _isEraser = false;
  CanvasBackground _background = CanvasBackground.dark;
  int _pointerCount = 0;
  DrawingTool _activeTool = DrawingTool.pen;

  @override
  void initState() {
    super.initState();
    _background = widget.song.canvasBackground;
  }

  void _onStrokesChanged(List<DrawingStroke> strokes) {
    context.read<BandProvider>().updateSongStrokes(
      widget.bandId,
      widget.song.id,
      strokes,
    );
  }

  void _undo(Song song) {
    if (song.strokes.isEmpty) return;
    final newStrokes = List<DrawingStroke>.from(song.strokes)..removeLast();
    context.read<BandProvider>().updateSongStrokes(
      widget.bandId,
      widget.song.id,
      newStrokes,
    );
  }

  void _clear(Song song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Clear Drawing', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Delete all strokes?', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<BandProvider>().updateSongStrokes(
                widget.bandId,
                widget.song.id,
                [],
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final song = context.watch<BandProvider>().getSongs(widget.bandId)
        .firstWhere((s) => s.id == widget.song.id, orElse: () => widget.song);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(song.title),
            if (song.artist.isNotEmpty)
              Text(
                song.artist,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
          ],
        ),
        actions: [
          if (song.key.isNotEmpty)
            _MetaBadge(label: song.key),
          if (song.bpm != null) ...[
            const SizedBox(width: 6),
            _MetaBadge(label: '${song.bpm} BPM'),
          ],
          if (song.hasSolo) ...[
            const SizedBox(width: 6),
            _MetaBadge(label: 'S', color: Colors.red),
          ],
          if (song.hasBacking) ...[
            const SizedBox(width: 6),
            _MetaBadge(label: 'B', color: Colors.blue),
          ],
          const SizedBox(width: 8),
          // Toggle Metadaten
          IconButton(
            icon: Icon(
              _metaExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppTheme.textMuted,
            ),
            onPressed: () => setState(() => _metaExpanded = !_metaExpanded),
            tooltip: 'Metadata',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: ElevatedButton.icon(
              onPressed: () {
                final setlist = Setlist(
                  id: 'single',
                  name: song.title,
                  slots: [SongSlot(id: 'slot1', songId: song.id, order: 0)],
                );
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => LiveScreen(
                      setlist: setlist,
                      songs: [song],
                      singleSongMode: true,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Live'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Aufklappbare Metadaten
          if (_metaExpanded)
            _MetadataPanel(
              song: song,
              bandId: widget.bandId,
            ),
          // Toolbar
          DrawingToolbar(
            selectedColor: _selectedColor,
            selectedWidth: _selectedWidth,
            isEraser: _isEraser,
            background: _background,
            onUndo: () => _undo(song),
            onClear: () => _clear(song),
            onColorChanged: (c) => setState(() => _selectedColor = c),
            onWidthChanged: (w) => setState(() => _selectedWidth = w),
            onEraserToggled: (e) => setState(() => _isEraser = e),
            onBackgroundChanged: (b) {
              setState(() => _background = b);
              final updated = Song(
                id: song.id,
                title: song.title,
                artist: song.artist,
                key: song.key,
                bpm: song.bpm,
                notes: song.notes,
                abbreviation: song.abbreviation,
                intro: song.intro,
                outro: song.outro,
                hasSolo: song.hasSolo,
                hasBacking: song.hasBacking,
                canvasBackground: b,
                strokes: song.strokes,
                quickStrokes: song.quickStrokes,
              );
              context.read<BandProvider>().updateSong(widget.bandId, updated);
            },
          ),
          // Canvas
          // Canvas
          Expanded(
            child: Listener(
              onPointerDown: (_) => setState(() => _pointerCount++),
              onPointerUp: (_) => setState(() => _pointerCount--),
              onPointerCancel: (_) => setState(() => _pointerCount--),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                panEnabled: _pointerCount >= 2,
                scaleEnabled: _pointerCount >= 2,
                child: DrawingCanvas(
                  strokes: song.strokes,
                  editable: _pointerCount < 2,
                  selectedColor: _selectedColor,
                  selectedWidth: _selectedWidth,
                  isEraser: _isEraser,
                  onStrokesChanged: _onStrokesChanged,
                  background: _background,
                  onUndo: () => _undo(song),
                  onEraserToggled: (e) => setState(() => _isEraser = e),
                  onDoublePenButton: () {
                    setState(() {
                      _activeTool = _activeTool == DrawingTool.pen
                          ? DrawingTool.highlighter
                          : DrawingTool.pen;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataPanel extends StatefulWidget {
  final Song song;
  final String bandId;

  const _MetadataPanel({required this.song, required this.bandId});

  @override
  State<_MetadataPanel> createState() => _MetadataPanelState();
}

class _MetadataPanelState extends State<_MetadataPanel> {
  late TextEditingController _introController;
  late TextEditingController _outroController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _introController = TextEditingController(text: widget.song.intro);
    _outroController = TextEditingController(text: widget.song.outro);
    _notesController = TextEditingController(text: widget.song.notes);
  }

  @override
  void dispose() {
    _introController.dispose();
    _outroController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = Song(
      id: widget.song.id,
      title: widget.song.title,
      artist: widget.song.artist,
      key: widget.song.key,
      bpm: widget.song.bpm,
      notes: _notesController.text.trim(),
      abbreviation: widget.song.abbreviation,
      intro: _introController.text.trim(),
      outro: _outroController.text.trim(),
      hasSolo: widget.song.hasSolo,
      hasBacking: widget.song.hasBacking,
      strokes: widget.song.strokes,
      quickStrokes: widget.song.quickStrokes,
    );
    context.read<BandProvider>().updateSong(widget.bandId, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetaField(
                  controller: _introController,
                  label: 'Intro',
                  hint: 'e.g. Gitarren-Riff 4×',
                  onChanged: (_) => _save(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetaField(
                  controller: _outroController,
                  label: 'Outro',
                  hint: 'e.g. Hard Cut',
                  onChanged: (_) => _save(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Solo Switch
              _SwitchBadge(
                label: 'Solo',
                value: widget.song.hasSolo,
                color: Colors.red,
                onChanged: (v) {
                  final updated = Song(
                    id: widget.song.id,
                    title: widget.song.title,
                    artist: widget.song.artist,
                    key: widget.song.key,
                    bpm: widget.song.bpm,
                    notes: widget.song.notes,
                    abbreviation: widget.song.abbreviation,
                    intro: widget.song.intro,
                    outro: widget.song.outro,
                    hasSolo: v,
                    hasBacking: widget.song.hasBacking,
                    strokes: widget.song.strokes,
                    quickStrokes: widget.song.quickStrokes,
                  );
                  context.read<BandProvider>().updateSong(widget.bandId, updated);
                },
              ),
              const SizedBox(width: 16),
              // Backing Switch
              _SwitchBadge(
                label: 'Backing',
                value: widget.song.hasBacking,
                color: Colors.blue,
                onChanged: (v) {
                  final updated = Song(
                    id: widget.song.id,
                    title: widget.song.title,
                    artist: widget.song.artist,
                    key: widget.song.key,
                    bpm: widget.song.bpm,
                    notes: widget.song.notes,
                    abbreviation: widget.song.abbreviation,
                    intro: widget.song.intro,
                    outro: widget.song.outro,
                    hasSolo: widget.song.hasSolo,
                    hasBacking: v,
                    strokes: widget.song.strokes,
                    quickStrokes: widget.song.quickStrokes,
                  );
                  context.read<BandProvider>().updateSong(widget.bandId, updated);
                },
              ),
              const Spacer(),
              Expanded(
                flex: 3,
                child: _MetaField(
                  controller: _notesController,
                  label: 'Notes',
                  hint: 'Additional notes...',
                  onChanged: (_) => _save(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Function(String) onChanged;

  const _MetaField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            filled: true,
            fillColor: AppTheme.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          ),
        ),
      ],
    );
  }
}

class _SwitchBadge extends StatelessWidget {
  final String label;
  final bool value;
  final Color color;
  final Function(bool) onChanged;

  const _SwitchBadge({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: value ? color : AppTheme.textSecondary,
            fontWeight: value ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: color,
          activeTrackColor: color.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const _MetaBadge({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppTheme.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}