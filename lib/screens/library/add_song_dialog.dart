import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/song.dart';
import '../../theme/app_theme.dart';

class AddSongDialog extends StatefulWidget {
  const AddSongDialog({super.key});

  @override
  State<AddSongDialog> createState() => _AddSongDialogState();
}

class _AddSongDialogState extends State<AddSongDialog> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _keyController = TextEditingController();
  final _bpmController = TextEditingController();
  final _notesController = TextEditingController();
  final _abbreviationController = TextEditingController();
  final _introController = TextEditingController();
  final _outroController = TextEditingController();
  bool _hasSolo = false;
  bool _hasBacking = false;

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _keyController.dispose();
    _bpmController.dispose();
    _notesController.dispose();
    _abbreviationController.dispose();
    _introController.dispose();
    _outroController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    final song = Song(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      artist: _artistController.text.trim(),
      key: _keyController.text.trim(),
      bpm: int.tryParse(_bpmController.text.trim()),
      notes: _notesController.text.trim(),
      abbreviation: _abbreviationController.text.trim(),
      intro: _introController.text.trim(),
      outro: _outroController.text.trim(),
      hasSolo: _hasSolo,
      hasBacking: _hasBacking,
    );
    Navigator.of(context).pop(song);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      title: const Text('Add Song', style: TextStyle(color: AppTheme.textPrimary)),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Field(controller: _titleController, label: 'Title *', hint: 'Song title'),
              const SizedBox(height: 12),
              _Field(controller: _artistController, label: 'Artist', hint: 'Artist name'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Field(controller: _keyController, label: 'Key', hint: 'A, Bb, C#...'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Field(
                      controller: _bpmController,
                      label: 'BPM',
                      hint: '120',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Field(controller: _abbreviationController, label: 'Abbreviation', hint: 'e.g. JBG, V8...'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Field(controller: _introController, label: 'Intro', hint: 'e.g. Gitarren-Riff 4×'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Field(controller: _outroController, label: 'Outro', hint: 'e.g. Hard Cut'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Solo Switch
                  Text('Solo', style: TextStyle(color: _hasSolo ? Colors.red : AppTheme.textSecondary, fontSize: 13)),
                  Switch(
                    value: _hasSolo,
                    onChanged: (v) => setState(() => _hasSolo = v),
                    activeThumbColor: Colors.red,
                    activeTrackColor: Colors.red.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 16),
                  // Backing Switch
                  Text('Backing', style: TextStyle(color: _hasBacking ? Colors.blue : AppTheme.textSecondary, fontSize: 13)),
                  Switch(
                    value: _hasBacking,
                    onChanged: (v) => setState(() => _hasBacking = v),
                    activeThumbColor: Colors.blue,
                    activeTrackColor: Colors.blue.withValues(alpha: 0.3),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _notesController,
                label: 'Notes',
                hint: 'Additional notes...',
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Song'),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textMuted),
            filled: true,
            fillColor: AppTheme.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}