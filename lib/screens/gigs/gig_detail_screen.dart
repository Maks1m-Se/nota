import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/gig.dart';
import '../../models/song.dart';
import '../../providers/band_provider.dart';
import '../../theme/app_theme.dart';
import '../live/live_screen.dart';

class GigDetailScreen extends StatefulWidget {
  final Gig gig;
  final List<Song> songs;
  final String bandId;

  const GigDetailScreen({
    super.key,
    required this.gig,
    required this.songs,
    required this.bandId,
  });

  @override
  State<GigDetailScreen> createState() => _GigDetailScreenState();
}

class _GigDetailScreenState extends State<GigDetailScreen> {
  late Gig _gig;

  @override
  void initState() {
    super.initState();
    _gig = widget.gig;
  }

  void _save() {
    context.read<BandProvider>().updateGig(widget.bandId, _gig);
  }

  void _addSetlist() async {
    final provider = context.read<BandProvider>();
    final availableSetlists = provider.getSetlists(widget.bandId);
    final alreadyAdded = _gig.setlists.map((s) => s.id).toSet();
    final available = availableSetlists.where((s) => !alreadyAdded.contains(s.id)).toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No setlists available. Create one in Setlists first.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      builder: (context) => Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Add Setlist',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: available.length,
              itemBuilder: (context, index) {
                final setlist = available[index];
                return ListTile(
                  title: Text(setlist.name, style: const TextStyle(color: AppTheme.textPrimary)),
                  subtitle: Text('${setlist.slots.length} Songs', style: const TextStyle(color: AppTheme.textSecondary)),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _gig = Gig(
                        id: _gig.id,
                        name: _gig.name,
                        venue: _gig.venue,
                        date: _gig.date,
                        time: _gig.time,
                        soundcheckTime: _gig.soundcheckTime,
                        setting: _gig.setting,
                        fee: _gig.fee,
                        organizer: _gig.organizer,
                        notes: _gig.notes,
                        setlists: [..._gig.setlists, setlist],
                      );
                    });
                    _save();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_gig.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _gig.setlists.isNotEmpty
                  ? () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => LiveScreen(
                            setlist: _gig.setlists.first,
                            songs: widget.songs,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addSetlist,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DETAILS', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  if (_gig.date != null)
                    _DetailRow(icon: Icons.calendar_today, label: '${_gig.date!.day}.${_gig.date!.month}.${_gig.date!.year}'),
                  if (_gig.time.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _DetailRow(icon: Icons.access_time, label: _gig.time),
                  ],
                  if (_gig.soundcheckTime.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _DetailRow(icon: Icons.settings_input_antenna, label: 'Soundcheck: ${_gig.soundcheckTime}'),
                  ],
                  if (_gig.venue.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _DetailRow(icon: Icons.location_on, label: _gig.venue),
                  ],
                  if (_gig.setting.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _DetailRow(icon: Icons.place, label: _gig.setting),
                  ],
                  if (_gig.fee.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _DetailRow(icon: Icons.euro, label: _gig.fee),
                  ],
                  if (_gig.organizer.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _DetailRow(icon: Icons.person, label: _gig.organizer),
                  ],
                  if (_gig.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _DetailRow(icon: Icons.notes, label: _gig.notes),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('SETLISTS', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          if (_gig.setlists.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No setlists yet. Tap + to add one.', style: TextStyle(color: AppTheme.textMuted)),
            ),
          ..._gig.setlists.asMap().entries.map((entry) {
            final i = entry.key;
            final setlist = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Text('${i + 1}'.padLeft(2, '0'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                title: Text(setlist.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
                subtitle: Text('${setlist.slots.length} Songs', style: const TextStyle(color: AppTheme.textSecondary)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (context) => LiveScreen(
                              setlist: setlist,
                              songs: widget.songs,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Live'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () {
                        setState(() {
                          _gig = Gig(
                            id: _gig.id,
                            name: _gig.name,
                            venue: _gig.venue,
                            date: _gig.date,
                            time: _gig.time,
                            soundcheckTime: _gig.soundcheckTime,
                            setting: _gig.setting,
                            fee: _gig.fee,
                            organizer: _gig.organizer,
                            notes: _gig.notes,
                            setlists: _gig.setlists.where((s) => s.id != setlist.id).toList(),
                          );
                        });
                        _save();
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
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
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
      ],
    );
  }
}