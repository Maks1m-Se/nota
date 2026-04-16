import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/band_provider.dart';
import '../../theme/app_theme.dart';
import 'song_detail_screen.dart';

class LibraryScreen extends StatelessWidget {
  final String bandId;

  const LibraryScreen({super.key, required this.bandId});

  @override
  Widget build(BuildContext context) {
    final songs = context.watch<BandProvider>().getSongs(bandId);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
                          builder: (context) => SongDetailScreen(song: song),
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