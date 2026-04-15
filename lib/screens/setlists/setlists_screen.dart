import 'package:flutter/material.dart';
import '../../models/setlist.dart';
import '../../models/song_slot.dart';
import '../../theme/app_theme.dart';

class SetlistsScreen extends StatefulWidget {
  final String bandId;

  const SetlistsScreen({super.key, required this.bandId});

  @override
  State<SetlistsScreen> createState() => _SetlistsScreenState();
}

class _SetlistsScreenState extends State<SetlistsScreen> {
  final List<Setlist> _setlists = [
    Setlist(
      id: '1',
      name: 'Stadtfest – Set 1',
      slots: [
        SongSlot(id: 's1', songId: '1', order: 0),
        SongSlot(id: 's2', songId: '2', order: 1),
        SongSlot(id: 's3', songId: '3', order: 2),
      ],
    ),
    Setlist(
      id: '2',
      name: 'Stadtfest – Set 2',
      slots: [
        SongSlot(id: 's4', songId: '4', order: 0),
        SongSlot(id: 's5', songId: '5', order: 1),
      ],
    ),
    Setlist(
      id: '3',
      name: 'Standard Abend',
      slots: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setlisten'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _setlists.length,
        itemBuilder: (context, index) {
          final setlist = _setlists[index];
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
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
