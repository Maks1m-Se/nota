import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/practice_item.dart';
import '../../models/song.dart';
import '../../providers/band_provider.dart';
import '../../theme/app_theme.dart';

/// Capture-Dialog für Practice-Items. Zwei Aufruf-Modi:
/// - fixedSongId gesetzt (Song-AppBar): Song fest gebunden, kein Dropdown.
/// - fixedSongId null (Practice-Tab): Song-Dropdown, auch song-lose Items.
class AddPracticeItemDialog extends StatefulWidget {
  final String bandId;
  final String? fixedSongId;

  const AddPracticeItemDialog({
    super.key,
    required this.bandId,
    this.fixedSongId,
  });

  @override
  State<AddPracticeItemDialog> createState() => _AddPracticeItemDialogState();
}

class _AddPracticeItemDialogState extends State<AddPracticeItemDialog> {
  final _textController = TextEditingController();
  PracticePriority _priority = PracticePriority.medium;
  String? _selectedSongId;

  @override
  void initState() {
    super.initState();
    _selectedSongId = widget.fixedSongId;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_textController.text.trim().isEmpty) return;
    final item = PracticeItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _textController.text.trim(),
      songId: _selectedSongId,
      priority: _priority,
      done: false,
      createdAt: DateTime.now(),
    );
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    final songs = List<Song>.from(
        context.read<BandProvider>().getSongs(widget.bandId))
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    final fixedSong = widget.fixedSongId != null
        ? songs.where((s) => s.id == widget.fixedSongId).firstOrNull
        : null;

    return AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      title: const Text('To Practice', style: TextStyle(color: AppTheme.textPrimary)),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _textController,
              autofocus: true,
              maxLines: 3,
              minLines: 1,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Was üben? *',
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            // Song-Bindung: fest (AppBar-Modus) oder Dropdown (Practice-Tab)
            if (widget.fixedSongId != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  fixedSong?.title ?? 'Song',
                  style: const TextStyle(
                      color: AppTheme.primaryColor, fontSize: 13),
                ),
              )
            else
              DropdownButtonFormField<String?>(
                initialValue: _selectedSongId,
                dropdownColor: AppTheme.surfaceColor,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Song',
                  labelStyle:
                      const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Allgemein',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                  ...songs.map((s) => DropdownMenuItem<String?>(
                        value: s.id,
                        child: Text(s.title, overflow: TextOverflow.ellipsis),
                      )),
                ],
                onChanged: (value) => setState(() => _selectedSongId = value),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Prio:',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(width: 12),
                _PrioChip(
                  label: 'H',
                  selected: _priority == PracticePriority.high,
                  onTap: () => setState(() => _priority = PracticePriority.high),
                ),
                const SizedBox(width: 8),
                _PrioChip(
                  label: 'M',
                  selected: _priority == PracticePriority.medium,
                  onTap: () =>
                      setState(() => _priority = PracticePriority.medium),
                ),
                const SizedBox(width: 8),
                _PrioChip(
                  label: 'N',
                  selected: _priority == PracticePriority.low,
                  onTap: () => setState(() => _priority = PracticePriority.low),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel',
              style: TextStyle(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.practiceColor,
            foregroundColor: Colors.black,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _PrioChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PrioChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.practiceColor.withValues(alpha: 0.2)
              : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? AppTheme.practiceColor
                : AppTheme.textMuted.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.practiceColor : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
