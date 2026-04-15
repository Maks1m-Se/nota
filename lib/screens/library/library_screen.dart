import 'package:flutter/material.dart';
import '../../models/song.dart';
import '../../theme/app_theme.dart';
import 'song_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  final String bandId;

  const LibraryScreen({super.key, required this.bandId});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Song> _songs = [
    Song(id: '1', title: 'Johnny B. Goode', artist: 'Chuck Berry', key: 'A', bpm: 130),
    Song(id: '2', title: 'Blue Suede Shoes', artist: 'Elvis Presley', key: 'C', bpm: 120),
    Song(id: '3', title: 'Rock Around the Clock', artist: 'Bill Haley', key: 'D', bpm: 175),
    Song(id: '4', title: 'Jailhouse Rock', artist: 'Elvis Presley', key: 'E', bpm: 168),
    Song(id: '5', title: 'Peggy Sue', artist: 'Buddy Holly', key: 'A', bpm: 160),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _songs.length,
        itemBuilder: (context, index) {
          final song = _songs[index];
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