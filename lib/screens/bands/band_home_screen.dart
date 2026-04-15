import 'package:flutter/material.dart';
import '../../models/band.dart';
import '../../theme/app_theme.dart';
import '../library/library_screen.dart';

class BandHomeScreen extends StatelessWidget {
  final Band band;

  const BandHomeScreen({super.key, required this.band});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(band.name),
            if (band.genre.isNotEmpty)
              Text(
                band.genre,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _NavCard(
              icon: Icons.library_music,
              label: 'Library',
              subtitle: 'Alle Songs der Band',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LibraryScreen(bandId: band.id),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _NavCard(
              icon: Icons.list,
              label: 'Setlisten',
              subtitle: 'Setlisten verwalten',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _NavCard(
              icon: Icons.calendar_today,
              label: 'Gigs',
              subtitle: 'Auftritte und Events',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Icon(icon, color: AppTheme.primaryColor, size: 28),
        title: Text(
          label,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
        onTap: onTap,
      ),
    );
  }
}