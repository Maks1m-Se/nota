import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/band_provider.dart';
import '../../models/gig.dart';
import '../../models/song.dart';
import '../../theme/app_theme.dart';
import 'gig_detail_screen.dart';
import 'add_gig_dialog.dart';
import 'edit_gig_dialog.dart';

class GigsScreen extends StatelessWidget {
  final String bandId;

  const GigsScreen({super.key, required this.bandId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BandProvider>();
    final gigs = provider.getGigs(bandId);
    final songs = provider.getSongs(bandId);
    final now = DateTime.now();

    final upcoming = gigs.where((g) => g.date == null || g.date!.isAfter(now)).toList();
    final past = gigs.where((g) => g.date != null && g.date!.isBefore(now)).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final gig = await showDialog<Gig>(
            context: context,
            builder: (context) => const AddGigDialog(),
          );
          if (gig != null && context.mounted) {
            context.read<BandProvider>().addGig(bandId, gig);
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: gigs.isEmpty
          ? const Center(
              child: Text(
                'No gigs yet. Tap + to add one.',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (upcoming.isNotEmpty) ...[
                  const Text('UPCOMING', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, letterSpacing: 0.8)),
                  const SizedBox(height: 8),
                  ...upcoming.map((gig) => _GigCard(gig: gig, isPast: false, songs: songs, bandId: bandId)),
                  const SizedBox(height: 20),
                ],
                if (past.isNotEmpty) ...[
                  const Text('PAST', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, letterSpacing: 0.8)),
                  const SizedBox(height: 8),
                  ...past.map((gig) => _GigCard(gig: gig, isPast: true, songs: songs, bandId: bandId)),
                ],
              ],
            ),
    );
  }
}

class _GigCard extends StatelessWidget {
  final Gig gig;
  final bool isPast;
  final List<Song> songs;
  final String bandId;

  const _GigCard({required this.gig, required this.isPast, required this.songs, required this.bandId});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isPast ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _DateBox(date: gig.date),
          title: Text(gig.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          subtitle: Text(gig.venue, style: const TextStyle(color: AppTheme.textSecondary)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.textMuted.withValues(alpha: 0.3)),
            ),
            child: Text('${gig.setlists.length} Sets', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GigDetailScreen(gig: gig, songs: songs, bandId: bandId),
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
                    title: const Text('Edit', style: TextStyle(color: AppTheme.textPrimary)),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final updated = await showDialog<Gig>(
                        context: context,
                        builder: (context) => EditGigDialog(gig: gig),
                      );
                      if (updated != null && context.mounted) {
                        context.read<BandProvider>().updateGig(bandId, updated);
                      }
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
                          title: const Text('Delete Gig', style: TextStyle(color: AppTheme.textPrimary)),
                          content: Text('Delete "${gig.name}"?', style: const TextStyle(color: AppTheme.textSecondary)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.read<BandProvider>().deleteGig(bandId, gig.id);
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
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
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final DateTime? date;

  const _DateBox({required this.date});

  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox(width: 48);
    const months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${date!.day}', style: const TextStyle(color: AppTheme.primaryColor, fontSize: 16, fontWeight: FontWeight.w500, height: 1)),
          const SizedBox(height: 2),
          Text(months[date!.month - 1], style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}