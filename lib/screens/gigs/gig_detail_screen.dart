import 'package:flutter/material.dart';
import '../../models/gig.dart';
import '../../models/song.dart';
import '../../theme/app_theme.dart';
import '../live/live_screen.dart';

class GigDetailScreen extends StatelessWidget {
  final Gig gig;
  final List<Song> songs;

  const GigDetailScreen({
    super.key,
    required this.gig,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gig.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: gig.setlists.isNotEmpty
                  ? () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => LiveScreen(
                            setlist: gig.setlists.first,
                            songs: songs,
                          ),
                        ),
                      );
                    }
                  : null,
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Gig Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DETAILS',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (gig.date != null)
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: _formatDate(gig.date!),
                    ),
                  if (gig.venue.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.location_on,
                      label: gig.venue,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Setlists
          const Text(
            'SETLISTS',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          ...gig.setlists.asMap().entries.map((entry) {
            final i = entry.key;
            final setlist = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Text(
                  '${i + 1}'.padLeft(2, '0'),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                title: Text(
                  setlist.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '${setlist.slots.length} Songs',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textMuted,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day}. ${months[date.month - 1]} ${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textMuted, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}