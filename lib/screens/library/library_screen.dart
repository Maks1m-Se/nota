import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/band_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/song.dart';
import 'song_detail_screen.dart';
import 'add_song_dialog.dart';
import 'edit_song_dialog.dart';

enum SongSortOrder { titleAZ, titleZA, keyAZ, keyZA, createdNewest, createdOldest }

class LibraryScreen extends StatefulWidget {
  final String bandId;

  const LibraryScreen({super.key, required this.bandId});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  SongSortOrder _sortOrder = SongSortOrder.titleAZ;

  List<Song> _sortedSongs(List<Song> songs) {
    final sorted = List<Song>.from(songs);
    switch (_sortOrder) {
      case SongSortOrder.titleAZ:
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case SongSortOrder.titleZA:
        sorted.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
      case SongSortOrder.keyAZ:
        sorted.sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));
      case SongSortOrder.keyZA:
        sorted.sort((a, b) => b.key.toLowerCase().compareTo(a.key.toLowerCase()));
      case SongSortOrder.createdNewest:
        sorted.sort((a, b) => b.id.compareTo(a.id));
      case SongSortOrder.createdOldest:
        sorted.sort((a, b) => a.id.compareTo(b.id));
    }
    return sorted;
  }

  String _sortLabel() {
    switch (_sortOrder) {
      case SongSortOrder.titleAZ: return 'A → Z';
      case SongSortOrder.titleZA: return 'Z → A';
      case SongSortOrder.keyAZ: return 'Key A → Z';
      case SongSortOrder.keyZA: return 'Key Z → A';
      case SongSortOrder.createdNewest: return 'Newest first';
      case SongSortOrder.createdOldest: return 'Oldest first';
    }
  }

  @override
  Widget build(BuildContext context) {
    final songs = context.watch<BandProvider>().getSongs(widget.bandId);
    final sorted = _sortedSongs(songs);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final song = await showDialog<Song>(
            context: context,
            builder: (context) => const AddSongDialog(),
          );
          if (song != null && context.mounted) {
            context.read<BandProvider>().addSong(widget.bandId, song);
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Sort bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.surfaceColor,
            child: Row(
              children: [
                const Icon(Icons.sort, color: AppTheme.textMuted, size: 16),
                const SizedBox(width: 8),
                const Text('Sort:', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(width: 8),
                PopupMenuButton<SongSortOrder>(
                  initialValue: _sortOrder,
                  color: AppTheme.surfaceColor,
                  onSelected: (value) => setState(() => _sortOrder = value),
                  child: Row(
                    children: [
                      Text(
                        _sortLabel(),
                        style: const TextStyle(color: AppTheme.primaryColor, fontSize: 13),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor, size: 18),
                    ],
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: SongSortOrder.titleAZ, child: Text('Title A → Z')),
                    const PopupMenuItem(value: SongSortOrder.titleZA, child: Text('Title Z → A')),
                    const PopupMenuItem(value: SongSortOrder.keyAZ, child: Text('Key A → Z')),
                    const PopupMenuItem(value: SongSortOrder.keyZA, child: Text('Key Z → A')),
                    const PopupMenuItem(value: SongSortOrder.createdNewest, child: Text('Newest first')),
                    const PopupMenuItem(value: SongSortOrder.createdOldest, child: Text('Oldest first')),
                  ],
                ),
                const Spacer(),
                Text(
                  '${sorted.length} Songs',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          // Song list
          Expanded(
            child: sorted.isEmpty
                ? const Center(
                    child: Text(
                      'No songs yet. Tap + to add one.',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) {
                      final song = sorted[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
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
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(
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
                                    leading: const Icon(Icons.edit, color: AppTheme.textSecondary),
                                    title: const Text('Edit', style: TextStyle(color: AppTheme.textPrimary)),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      showDialog(
                                        context: context,
                                        builder: (context) => EditSongDialog(
                                          song: song,
                                          bandId: widget.bandId,
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.delete, color: Colors.red),
                                    title: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: AppTheme.surfaceColor,
                                          title: const Text('Delete Song', style: TextStyle(color: AppTheme.textPrimary)),
                                          content: Text('Delete "${song.title}"?', style: const TextStyle(color: AppTheme.textSecondary)),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                context.read<BandProvider>().deleteSong(widget.bandId, song.id);
                                                Navigator.of(context).pop();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}