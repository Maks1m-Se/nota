import 'package:flutter/material.dart';
import '../../models/band.dart';
import '../../theme/app_theme.dart';

/// Dialog zum Anlegen einer Band. Gibt die fertige Band per pop zurück —
/// das Persistieren (addBand) macht der Aufrufer.
class AddBandDialog extends StatefulWidget {
  const AddBandDialog({super.key});

  @override
  State<AddBandDialog> createState() => _AddBandDialogState();
}

class _AddBandDialogState extends State<AddBandDialog> {
  final _nameController = TextEditingController();
  final _genreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Rebuild, damit der Anlegen-Button auf leeren Namen reagiert.
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
    final band = Band(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
        'Neue Band',
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
              hint: 'z.B. PRIMEBEATS',
              autofocus: true,
            ),
            const SizedBox(height: 12),
            _field(
              label: 'Genre',
              controller: _genreController,
              hint: "z.B. Rockabilly / 50s Rock'n'Roll",
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Abbrechen',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _canSubmit ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Anlegen'),
        ),
      ],
    );
  }
}
