import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/band_provider.dart';
import '../../theme/app_theme.dart';
import 'setlist_detail_screen.dart';

class SetlistsScreen extends StatelessWidget {
  final String bandId;

  const SetlistsScreen({super.key, required this.bandId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BandProvider>();
    final setlists = provider.getSetlists(bandId);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: setlists.isEmpty
          ? const Center(
              child: Text(
                'No setlists yet. Tap + to add one.',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: setlists.length,
              itemBuilder: (context, index) {
                final setlist = setlists[index];
                final songs = provider.getSongsForSetlist(bandId, setlist);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SetlistDetailScreen(
                            setlist: setlist,
                            songs: songs,
                          ),
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