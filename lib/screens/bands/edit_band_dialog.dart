import 'package:flutter/material.dart';
import '../../models/band.dart';
import '../../theme/app_theme.dart';

/// Dialog zum Bearbeiten einer Band (Name + Genre, beide vorbelegt).
/// Bewusst als Edit- und nicht als Rename-Dialog geschnitten: spätere
/// Band-Felder (Farbe etc.) kommen hier dazu, statt den Dialog zu ersetzen.
/// Gibt die aktualisierte Band per pop zurück — updateBand macht der Aufrufer.
class EditBandDialog extends StatefulWidget {
  final Band band;

  const EditBandDialog({super.key, required this.band});

  @override
  State<EditBandDialog> createState() => _EditBandDialogState();
}

class _EditBandDialogState extends State<EditBandDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _genreController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.band.name);
    _genreController = TextEditingController(text: widget.band.genre);
    // Rebuild, damit der Save-Button auf leeren Namen reagiert.
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _nameController.text.trim().isNotEmpty;

  void _submit() {
    if (!_canSubmit) return;
    // id bleibt, alle Felder explizit gesetzt (kein copy-with).
    final band = Band(
      id: widget.band.id,
      name: _nameController.text.trim(),
      genre: _genreController.text.trim(),
    );
    Navigator.of(context).pop(band);
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool autofocus = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          autofocus: autofocus,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          onSubmitted: (_) => _submit(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      title: const Text(
        'Edit Band',
        style: TextStyle(color: AppTheme.textPrimary),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field(
              label: 'Name *',
              controller: _nameController,
              hint: 'e.g. PRIMEBEATS',
              autofocus: true,
            ),
            const SizedBox(height: 12),
            _field(
              label: 'Genre',
              controller: _genreController,
              hint: "e.g. Rockabilly / 50s Rock'n'Roll",
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _canSubmit ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
