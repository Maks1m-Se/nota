import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/band_provider.dart';
import '../../theme/app_theme.dart';
import 'band_scaffold.dart';
import '../settings/settings_screen.dart';

class BandListScreen extends StatelessWidget {
  const BandListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BandProvider>();
    final bands = provider.bands;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bands'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.textMuted),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bands.length,
        itemBuilder: (context, index) {
          final band = bands[index];
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
                    builder: (context) => BandScaffold(band: band),
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