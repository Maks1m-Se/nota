import 'package:flutter/material.dart';
import '../../models/song.dart';
import '../../theme/app_theme.dart';

class SongDetailScreen extends StatelessWidget {
  final Song song;

  const SongDetailScreen({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(song.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metadaten
            Row(
              children: [
                if (song.key.isNotEmpty) _MetaBadge(label: song.key),
                if (song.bpm != null) ...[
                  const SizedBox(width: 8),
                  _MetaBadge(label: '${song.bpm} BPM'),
                ],
                if (song.artist.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _MetaBadge(label: song.artist),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // Notizen
            const Text(
              'Notizen',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.textMuted.withValues(alpha: 0.3)),
              ),
              child: Text(
                song.notes.isNotEmpty ? song.notes : 'Keine Notizen vorhanden.',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Zeichnung Platzhalter
            const Text(
              'Zeichnung',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.textMuted.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Center(
                child: Text(
                  'Zeichenfläche (S Pen)',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              ),
            ),
          ],
        ),
      ),
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