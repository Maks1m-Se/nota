import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/band_provider.dart';
import '../../theme/app_theme.dart';
import 'song_detail_screen.dart';
import 'add_song_dialog.dart';
import '../../models/song.dart';
import 'edit_song_dialog.dart';

class LibraryScreen extends StatelessWidget {
  final String bandId;

  const LibraryScreen({super.key, required this.bandId});

  @override
  Widget build(BuildContext context) {
    final songs = context.watch<BandProvider>().getSongs(bandId);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final song = await showDialog<Song>(
            context: context,
            builder: (context) => const AddSongDialog(),
          );
          if (song != null && context.mounted) {
            context.read<BandProvider>().addSong(bandId, song);
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: songs.isEmpty
          ? const Center(
              child: Text(
                'No songs yet. Tap + to add one.',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SongDetailScreen(song: song, bandId: bandId),
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
                              title: const Text(
                                'Edit',
                                style: TextStyle(color: AppTheme.textPrimary),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  builder: (context) => EditSongDialog(song: song, bandId: bandId),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete, color: Colors.red),
                              title: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: AppTheme.surfaceColor,
                                    title: const Text(
                                      'Delete Song',
                                      style: TextStyle(color: AppTheme.textPrimary),
                                    ),
                                    content: Text(
                                      'Delete "${song.title}"?',
                                      style: const TextStyle(color: AppTheme.textSecondary),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(color: AppTheme.textSecondary),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          context.read<BandProvider>().deleteSong(bandId, song.id);
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
    );
  }
}