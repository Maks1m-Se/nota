import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/setlist.dart';
import '../../models/song.dart';
import '../../models/song_slot.dart';
import '../../providers/band_provider.dart';
import '../../theme/app_theme.dart';
import '../live/live_screen.dart';
import '../library/song_detail_screen.dart';

class SetlistDetailScreen extends StatefulWidget {
  final Setlist setlist;
  final List<Song> songs;
  final String bandId;

  const SetlistDetailScreen({
    super.key,
    required this.setlist,
    required this.songs,
    required this.bandId,
  });

  @override
  State<SetlistDetailScreen> createState() => _SetlistDetailScreenState();
}

class _SetlistDetailScreenState extends State<SetlistDetailScreen> {
  late Setlist _setlist;

  @override
  void initState() {
    super.initState();
    _setlist = widget.setlist;
  }

  List<Song> get _songs {
    final allSongs = context.read<BandProvider>().getSongs(widget.bandId);
    return _setlist.slots.map((slot) {
      return allSongs.firstWhere(
        (s) => s.id == slot.songId,
        orElse: () => Song(id: '', title: 'Unknown', key: ''),
      );
    }).toList();
  }

  void _save() {
    context.read<BandProvider>().updateSetlist(widget.bandId, _setlist);
  }

  void _addSong() async {
    final allSongs = context.read<BandProvider>().getSongs(widget.bandId);
    final alreadyAdded = _setlist.slots.map((s) => s.songId).toSet();
    final available = allSongs.where((s) => !alreadyAdded.contains(s.id)).toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All songs are already in this setlist.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      builder: (context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Add Song',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: available.length,
              itemBuilder: (context, index) {
                final song = available[index];
                return ListTile(
                  title: Text(
                    song.title,
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  subtitle: Text(
                    song.artist,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  trailing: song.key.isNotEmpty
                      ? Text(
                          song.key,
                          style: const TextStyle(color: AppTheme.primaryColor),
                        )
                      : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _setlist = Setlist(
                        id: _setlist.id,
                        name: _setlist.name,
                        slots: [
                          ..._setlist.slots,
                          SongSlot(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            songId: song.id,
                            order: _setlist.slots.length,
                          ),
                        ],
                      );
                    });
                    _save();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _removeSong(int index) {
    setState(() {
      final slots = List<SongSlot>.from(_setlist.slots)..removeAt(index);
      _setlist = Setlist(
        id: _setlist.id,
        name: _setlist.name,
        slots: slots.asMap().entries.map((e) => SongSlot(
          id: e.value.id,
          songId: e.value.songId,
          order: e.key,
        )).toList(),
      );
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final songs = _songs;

    return Scaffold(
      appBar: AppBar(
        title: Text(_setlist.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: songs.isEmpty
                  ? null
                  : () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => LiveScreen(
                            setlist: _setlist,
                            songs: songs,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addSong,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: songs.isEmpty
          ? const Center(
              child: Text(
                'No songs yet. Tap + to add songs.',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: songs.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final slots = List<SongSlot>.from(_setlist.slots);
                  final slot = slots.removeAt(oldIndex);
                  slots.insert(newIndex, slot);
                  _setlist = Setlist(
                    id: _setlist.id,
                    name: _setlist.name,
                    slots: slots.asMap().entries.map((e) => SongSlot(
                      id: e.value.id,
                      songId: e.value.songId,
                      order: e.key,
                    )).toList(),
                  );
                });
                _save();
              },
              itemBuilder: (context, index) {
                final song = songs[index];
                return Card(
                  key: ValueKey(_setlist.slots[index].id),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Text(
                      '${index + 1}'.padLeft(2, '0'),
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    title: Text(
                      song.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      song.artist,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SongDetailScreen(
                            song: song,
                            bandId: widget.bandId,
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: AppTheme.surfaceColor,
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit, color: AppTheme.textPrimary),
                              title: const Text('Edit Song', style: TextStyle(color: AppTheme.textPrimary)),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SongDetailScreen(
                                      song: song,
                                      bandId: widget.bandId,
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              title: const Text('Remove from Setlist', style: TextStyle(color: Colors.red)),
                              onTap: () {
                                Navigator.of(context).pop();
                                _removeSong(index);
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (song.key.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              song.key,
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red, size: 20),
                          onPressed: () => _removeSong(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}