import 'package:flutter/material.dart';
import '../../models/band.dart';
import '../../theme/app_theme.dart';
import 'band_home_screen.dart';

class BandListScreen extends StatefulWidget {
  const BandListScreen({super.key});

  @override
  State<BandListScreen> createState() => _BandListScreenState();
}

class _BandListScreenState extends State<BandListScreen> {
  final List<Band> _bands = [
    Band(id: '1', name: 'PRIMEBEATS', genre: 'Rockabilly / 50s Rock\'n\'Roll'),
    Band(id: '2', name: 'Jukebox22', genre: 'Rockabilly / 50s Rock\'n\'Roll'),
    Band(id: '3', name: 'Solo', genre: ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bands'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bands.length,
        itemBuilder: (context, index) {
          final band = _bands[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  band.name[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                band.name,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: band.genre.isNotEmpty
                  ? Text(
                      band.genre,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    )
                  : null,
              trailing: const Icon(
                Icons.chevron_right,
                color: AppTheme.textMuted,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BandHomeScreen(band: band),
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