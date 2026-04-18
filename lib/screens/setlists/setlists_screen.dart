import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/band_provider.dart';
import '../../models/setlist.dart';
import '../../theme/app_theme.dart';
import 'setlist_detail_screen.dart';
import 'add_setlist_dialog.dart';

class SetlistsScreen extends StatelessWidget {
  final String bandId;

  const SetlistsScreen({super.key, required this.bandId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BandProvider>();
    final setlists = provider.getSetlists(bandId);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final setlist = await showDialog<Setlist>(
            context: context,
            builder: (context) => const AddSetlistDialog(),
          );
          if (setlist != null && context.mounted) {
            context.read<BandProvider>().addSetlist(bandId, setlist);
          }
        },
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
                final setlistSongs = provider.getSongsForSetlist(bandId, setlist);
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
                            songs: setlistSongs,
                            bandId: bandId,
                          ),
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
                                'Rename',
                                style: TextStyle(color: AppTheme.textPrimary),
                              ),
                              onTap: () async {
                                Navigator.of(context).pop();
                                final controller = TextEditingController(text: setlist.name);
                                final newName = await showDialog<String>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: AppTheme.surfaceColor,
                                    title: const Text('Rename Setlist', style: TextStyle(color: AppTheme.textPrimary)),
                                    content: TextField(
                                      controller: controller,
                                      autofocus: true,
                                      style: const TextStyle(color: AppTheme.textPrimary),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: AppTheme.backgroundColor,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryColor,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  ),
                                );
                                if (newName != null && newName.isNotEmpty && context.mounted) {
                                  final updated = Setlist(
                                    id: setlist.id,
                                    name: newName,
                                    slots: setlist.slots,
                                  );
                                  context.read<BandProvider>().updateSetlist(bandId, updated);
                                }
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
                                    title: const Text('Delete Setlist', style: TextStyle(color: AppTheme.textPrimary)),
                                    content: Text(
                                      'Delete "${setlist.name}"?',
                                      style: const TextStyle(color: AppTheme.textSecondary),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          context.read<BandProvider>().deleteSetlist(bandId, setlist.id);
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