import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song.dart';
import '../../providers/band_provider.dart';
import '../../theme/app_theme.dart';

/// Songs aus einer anderen Band in [targetBandId] übernehmen — Vollkopie
/// mit eigener ID und eigener Chart-Datei (BandProvider.copySongsToBand).
class ImportSongsScreen extends StatefulWidget {
  final String targetBandId;

  const ImportSongsScreen({super.key, required this.targetBandId});

  @override
  State<ImportSongsScreen> createState() => _ImportSongsScreenState();
}

class _ImportSongsScreenState extends State<ImportSongsScreen> {
  String? _sourceBandId;
  final Set<String> _selected = {};

  // Sperrt Button, Auswahl und Zurück, solange die Datei-Kopien laufen —
  // ein zweiter Tap würde den ganzen Batch doppelt kopieren.
  bool _copying = false;

  void _toggle(String songId) {
    setState(() {
      if (!_selected.remove(songId)) _selected.add(songId);
    });
  }

  Future<void> _copy(String sourceBandId, List<String> songIds) async {
    if (_copying || songIds.isEmpty) return;
    setState(() => _copying = true);
    // Vor dem await capturen — nach pop ist der Context nicht mehr gültig.
    final provider = context.read<BandProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final result =
        await provider.copySongsToBand(sourceBandId, widget.targetBandId, songIds);
    if (!mounted) return;
    navigator.pop();
    final n = result.copied;
    final label = '$n ${n == 1 ? 'Song' : 'Songs'} kopiert';
    messenger.showSnackBar(
      SnackBar(
        content: Text(result.chartFailed == 0
            ? label
            : '$label, ${result.chartFailed} ohne Chart'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BandProvider>();
    final otherBands =
        provider.bands.where((b) => b.id != widget.targetBandId).toList();
    final targetName = provider.bands
            .where((b) => b.id == widget.targetBandId)
            .firstOrNull
            ?.name ??
        '';
    // Default: erste andere Band. Auswahl ungültig (Band gelöscht) → Default.
    final source = otherBands.where((b) => b.id == _sourceBandId).firstOrNull ??
        otherBands.firstOrNull;

    // Alphabetisch nach Titel — bewusst nicht die Library-Sortierlogik.
    final songs = source == null
        ? <Song>[]
        : (List<Song>.of(provider.getSongs(source.id))
          ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase())));
    // Auswahl nur gegen die aktuelle Quelle zählen; Reihenfolge = Anzeige.
    final selectedIds =
        songs.where((s) => _selected.contains(s.id)).map((s) => s.id).toList();
    final allSelected = songs.isNotEmpty && selectedIds.length == songs.length;

    return PopScope(
      canPop: !_copying,
      child: Scaffold(
        appBar: AppBar(title: const Text('Import Songs')),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: AppTheme.surfaceColor,
              child: Row(
                children: [
                  const Text('From band',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                  const SizedBox(width: 12),
                  if (source == null)
                    const Text('No other bands',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14))
                  else
                    DropdownButton<String>(
                      value: source.id,
                      dropdownColor: AppTheme.surfaceColor,
                      underline: const SizedBox.shrink(),
                      style: const TextStyle(color: AppTheme.primaryColor, fontSize: 14),
                      iconEnabledColor: AppTheme.primaryColor,
                      items: otherBands
                          .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                          .toList(),
                      onChanged: _copying
                          ? null
                          : (id) => setState(() {
                                _sourceBandId = id;
                                _selected.clear();
                              }),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: songs.isEmpty || _copying
                        ? null
                        : () => setState(() {
                              if (allSelected) {
                                _selected.clear();
                              } else {
                                _selected.addAll(songs.map((s) => s.id));
                              }
                            }),
                    child: Text(allSelected ? 'Deselect all' : 'Select all'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: songs.isEmpty
                  ? Center(
                      child: Text(
                        source == null
                            ? 'Create another band first.'
                            : 'No songs in ${source.name}.',
                        style: const TextStyle(color: AppTheme.textMuted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        final hasChart = song.chordChartFile != null ||
                            song.chordChartBase64 != null;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            enabled: !_copying,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            leading: Checkbox(
                              value: _selected.contains(song.id),
                              activeColor: AppTheme.primaryColor,
                              onChanged: _copying ? null : (_) => _toggle(song.id),
                            ),
                            title: Text(song.title,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w500)),
                            subtitle: Text(song.artist,
                                style: const TextStyle(color: AppTheme.textSecondary)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasChart) ...[
                                  const Icon(Icons.description_outlined,
                                      color: AppTheme.textSecondary, size: 18),
                                  const SizedBox(width: 8),
                                ],
                                if (song.key.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: AppTheme.primaryColor
                                              .withValues(alpha: 0.4)),
                                    ),
                                    child: Text(song.key,
                                        style: const TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500)),
                                  ),
                              ],
                            ),
                            onTap: () => _toggle(song.id),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppTheme.surfaceColor,
              child: Row(
                children: [
                  Text('${selectedIds.length} of ${songs.length} selected',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: source == null || selectedIds.isEmpty || _copying
                        ? null
                        : () => _copy(source.id, selectedIds),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _copying
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.textPrimary),
                          )
                        : Text('Copy to $targetName'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
