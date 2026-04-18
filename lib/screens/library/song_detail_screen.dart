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

class _SongDetailScreenState extends State<SongDetailScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _notesController;
  late TabController _tabController;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.song.notes);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _tabController.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.notes), text: 'Notes'),
            Tab(icon: Icon(Icons.draw), text: 'Drawing'),
          ],
        ),
        actions: [
          // Metadaten
          if (song.key.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Text(
                  song.key,
                  style: const TextStyle(color: AppTheme.primaryColor, fontSize: 13),
                ),
              ),
            ),
          if (song.bpm != null)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Text(
                  '${song.bpm} BPM',
                  style: const TextStyle(color: AppTheme.primaryColor, fontSize: 13),
                ),
              ),
            ),
          // Live Button
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 6),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Notes
          _editing
              ? Column(
                  children: [
                    Expanded(
                      child: Padding(
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
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () => setState(() => _editing = true),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: _notesController.text.isEmpty
                        ? const Text(
                            'Tap to add notes...',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
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

          // Tab 2: Drawing
          const Center(
            child: Text(
              'Drawing area (S Pen) — coming soon',
              style: TextStyle(color: AppTheme.textMuted),
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