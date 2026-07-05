import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/practice_item.dart';
import '../../models/song.dart';
import '../../providers/band_provider.dart';
import '../../theme/app_theme.dart';
import 'add_practice_item_dialog.dart';

enum PracticeSortOrder { priority, createdNewest }

class PracticeScreen extends StatefulWidget {
  final String bandId;

  const PracticeScreen({super.key, required this.bandId});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  PracticeSortOrder _sortOrder = PracticeSortOrder.priority;
  // Song-Filter: null = alle, '' = nur Allgemein (song-los), sonst songId
  String? _songFilter;
  PracticePriority? _prioFilter;

  List<PracticeItem> _applyFilters(List<PracticeItem> items) {
    var result = items;
    if (_songFilter != null) {
      result = result
          .where((p) => _songFilter == '' ? p.songId == null : p.songId == _songFilter)
          .toList();
    }
    if (_prioFilter != null) {
      result = result.where((p) => p.priority == _prioFilter).toList();
    }
    return result;
  }

  List<PracticeItem> _sorted(List<PracticeItem> items) {
    final sorted = List<PracticeItem>.from(items);
    switch (_sortOrder) {
      case PracticeSortOrder.priority:
        sorted.sort((a, b) {
          final byPrio = a.priority.index.compareTo(b.priority.index);
          if (byPrio != 0) return byPrio;
          return b.createdAt.compareTo(a.createdAt);
        });
      case PracticeSortOrder.createdNewest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return sorted;
  }

  String _sortLabel() {
    switch (_sortOrder) {
      case PracticeSortOrder.priority: return 'Prio';
      case PracticeSortOrder.createdNewest: return 'Hinzugefügt';
    }
  }

  String _songFilterLabel(List<Song> songs) {
    if (_songFilter == null) return 'Alle Songs';
    if (_songFilter == '') return 'Allgemein';
    final song = songs.where((s) => s.id == _songFilter).firstOrNull;
    return song?.title ?? 'Unknown';
  }

  String _prioFilterLabel() {
    switch (_prioFilter) {
      case null: return 'Alle Prios';
      case PracticePriority.high: return 'H';
      case PracticePriority.medium: return 'M';
      case PracticePriority.low: return 'N';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BandProvider>();
    final items = provider.getPracticeItems(widget.bandId);
    final songs = List<Song>.from(provider.getSongs(widget.bandId))
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    final filtered = _applyFilters(items);
    final open = _sorted(filtered.where((p) => !p.done).toList());
    final done = _sorted(filtered.where((p) => p.done).toList());

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final item = await showDialog<PracticeItem>(
            context: context,
            builder: (context) => AddPracticeItemDialog(bandId: widget.bandId),
          );
          if (item != null && context.mounted) {
            context.read<BandProvider>().addPracticeItem(widget.bandId, item);
          }
        },
        backgroundColor: AppTheme.practiceColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Column(
        children: [
          // Filter-/Sort-Leiste
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.surfaceColor,
            child: Row(
              children: [
                const Icon(Icons.sort, color: AppTheme.textMuted, size: 16),
                const SizedBox(width: 8),
                PopupMenuButton<PracticeSortOrder>(
                  initialValue: _sortOrder,
                  color: AppTheme.surfaceColor,
                  onSelected: (value) => setState(() => _sortOrder = value),
                  child: _FilterChipLabel(label: _sortLabel()),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                        value: PracticeSortOrder.priority, child: Text('Prio')),
                    PopupMenuItem(
                        value: PracticeSortOrder.createdNewest,
                        child: Text('Hinzugefügt')),
                  ],
                ),
                const SizedBox(width: 16),
                const Icon(Icons.filter_list, color: AppTheme.textMuted, size: 16),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  color: AppTheme.surfaceColor,
                  onSelected: (value) => setState(
                      () => _songFilter = value == '__all__' ? null : value),
                  child: _FilterChipLabel(label: _songFilterLabel(songs)),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: '__all__', child: Text('Alle Songs')),
                    const PopupMenuItem(value: '', child: Text('Allgemein')),
                    ...songs.map((s) => PopupMenuItem(
                          value: s.id,
                          child: Text(s.title, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                ),
                const SizedBox(width: 16),
                PopupMenuButton<int>(
                  color: AppTheme.surfaceColor,
                  onSelected: (value) => setState(() => _prioFilter =
                      value == -1 ? null : PracticePriority.values[value]),
                  child: _FilterChipLabel(label: _prioFilterLabel()),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: -1, child: Text('Alle Prios')),
                    PopupMenuItem(value: 0, child: Text('H — Hoch')),
                    PopupMenuItem(value: 1, child: Text('M — Mittel')),
                    PopupMenuItem(value: 2, child: Text('N — Niedrig')),
                  ],
                ),
                const Spacer(),
                Text(
                  '${open.length} offen',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: open.isEmpty && done.isEmpty
                ? Center(
                    child: Text(
                      items.isEmpty
                          ? 'Nichts zu üben. Tap + to add.'
                          : 'Keine Items für diesen Filter.',
                      style: const TextStyle(color: AppTheme.textMuted),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...open.map((item) => _PracticeRow(
                            item: item,
                            bandId: widget.bandId,
                            songs: songs,
                          )),
                      if (done.isNotEmpty)
                        Theme(
                          // Divider-Linien des ExpansionTile unterdrücken
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            title: Text(
                              'Erledigt (${done.length})',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 14),
                            ),
                            iconColor: AppTheme.textSecondary,
                            collapsedIconColor: AppTheme.textMuted,
                            children: done
                                .map((item) => _PracticeRow(
                                      item: item,
                                      bandId: widget.bandId,
                                      songs: songs,
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipLabel extends StatelessWidget {
  final String label;

  const _FilterChipLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.primaryColor, fontSize: 13),
          ),
        ),
        const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor, size: 18),
      ],
    );
  }
}

class _PracticeRow extends StatelessWidget {
  final PracticeItem item;
  final String bandId;
  final List<Song> songs;

  const _PracticeRow({
    required this.item,
    required this.bandId,
    required this.songs,
  });

  String _songLabel() {
    if (item.songId == null) return 'Allgemein';
    final song = songs.where((s) => s.id == item.songId).firstOrNull;
    return song?.title ?? 'Unknown';
  }

  String _prioLabel() {
    switch (item.priority) {
      case PracticePriority.high: return 'H';
      case PracticePriority.medium: return 'M';
      case PracticePriority.low: return 'N';
    }
  }

  Color _prioColor() {
    switch (item.priority) {
      case PracticePriority.high: return AppTheme.practiceColor;
      case PracticePriority.medium: return AppTheme.textSecondary;
      case PracticePriority.low: return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSongBound = item.songId != null;
    final prioColor = _prioColor();

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<BandProvider>().deletePracticeItem(bandId, item.id);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          leading: Checkbox(
            value: item.done,
            onChanged: (_) => context
                .read<BandProvider>()
                .togglePracticeItemDone(bandId, item.id),
            activeColor: AppTheme.practiceColor,
            checkColor: Colors.black,
            side: const BorderSide(color: AppTheme.textSecondary),
          ),
          title: Text(
            item.text,
            style: TextStyle(
              color: item.done ? AppTheme.textMuted : AppTheme.textPrimary,
              decoration: item.done ? TextDecoration.lineThrough : null,
              decorationColor: AppTheme.textMuted,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Song-Chip
              Container(
                constraints: const BoxConstraints(maxWidth: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSongBound
                      ? AppTheme.primaryColor.withValues(alpha: 0.15)
                      : AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSongBound
                        ? AppTheme.primaryColor.withValues(alpha: 0.4)
                        : AppTheme.textMuted.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  _songLabel(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSongBound
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Prio-Chip: Tap cyclet H → M → N
              GestureDetector(
                onTap: () => context
                    .read<BandProvider>()
                    .cyclePracticeItemPriority(bandId, item.id),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: prioColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: prioColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    _prioLabel(),
                    style: TextStyle(
                      color: prioColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
