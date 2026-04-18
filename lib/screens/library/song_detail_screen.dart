import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song.dart';
import '../../providers/band_provider.dart';
import '../../theme/app_theme.dart';
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
  late TextEditingController _notesController;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.song.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveNotes() {
    final updated = Song(
      id: widget.song.id,
      title: widget.song.title,
      artist: widget.song.artist,
      key: widget.song.key,
      bpm: widget.song.bpm,
      notes: _notesController.text.trim(),
    );
    context.read<BandProvider>().updateSong(widget.bandId, updated);
    setState(() => _editing = false);
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
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          // Live Button
          Padding(
            padding: const EdgeInsets.only(right: 12),
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
          // Metadaten
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.surfaceColor,
            child: Row(
              children: [
                if (song.key.isNotEmpty) _MetaBadge(label: song.key),
                if (song.bpm != null) ...[
                  const SizedBox(width: 8),
                  _MetaBadge(label: '${song.bpm} BPM'),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          // Notizen + Zeichnung
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Notizen
                  SizedBox(
                    height: 300,
                    child: _editing
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextField(
                              controller: _notesController,
                              maxLines: null,
                              expands: true,
                              autofocus: true,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                height: 1.7,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Add notes, chords, structure...',
                                hintStyle: TextStyle(color: AppTheme.textMuted),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () => setState(() => _editing = true),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              child: _notesController.text.isEmpty
                                  ? const Text(
                                      'Tap to add notes...',
                                      style: TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 16,
                                      ),
                                    )
                                  : Text(
                                      _notesController.text,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 16,
                                        height: 1.7,
                                      ),
                                    ),
                            ),
                          ),
                  ),
                  // Zeichnung Platzhalter
                  Container(
                    height: 200,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.textMuted.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Drawing area (S Pen) — coming soon',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _editing
          ? FloatingActionButton(
              onPressed: _saveNotes,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.check, color: Colors.white),
            )
          : null,
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final String label;

  const _MetaBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}