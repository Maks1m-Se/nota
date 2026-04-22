import 'package:flutter/material.dart';
import '../../models/gig.dart';
import '../../theme/app_theme.dart';

class EditGigDialog extends StatefulWidget {
  final Gig gig;

  const EditGigDialog({super.key, required this.gig});

  @override
  State<EditGigDialog> createState() => _EditGigDialogState();
}

class _EditGigDialogState extends State<EditGigDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _venueController;
  late final TextEditingController _timeController;
  late final TextEditingController _soundcheckController;
  late final TextEditingController _feeController;
  late final TextEditingController _organizerController;
  late final TextEditingController _notesController;
  late final TextEditingController _settingController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gig.name);
    _venueController = TextEditingController(text: widget.gig.venue);
    _timeController = TextEditingController(text: widget.gig.time);
    _soundcheckController = TextEditingController(text: widget.gig.soundcheckTime);
    _feeController = TextEditingController(text: widget.gig.fee);
    _organizerController = TextEditingController(text: widget.gig.organizer);
    _notesController = TextEditingController(text: widget.gig.notes);
    _settingController = TextEditingController(text: widget.gig.setting);
    _selectedDate = widget.gig.date;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    _timeController.dispose();
    _soundcheckController.dispose();
    _feeController.dispose();
    _organizerController.dispose();
    _notesController.dispose();
    _settingController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) return;
    final updated = Gig(
      id: widget.gig.id,
      name: _nameController.text.trim(),
      venue: _venueController.text.trim(),
      date: _selectedDate,
      time: _timeController.text.trim(),
      soundcheckTime: _soundcheckController.text.trim(),
      setting: _settingController.text.trim(),
      fee: _feeController.text.trim(),
      organizer: _organizerController.text.trim(),
      notes: _notesController.text.trim(),
      setlists: widget.gig.setlists,
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      title: const Text('Edit Gig', style: TextStyle(color: AppTheme.textPrimary)),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Name *'),
              _field(_nameController, 'e.g. Stadtfest'),
              const SizedBox(height: 12),
              _label('Venue'),
              _field(_venueController, 'e.g. Marktplatz'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Date'),
                        GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) setState(() => _selectedDate = date);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: AppTheme.textMuted, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedDate == null
                                      ? 'Select date'
                                      : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                                  style: TextStyle(
                                    color: _selectedDate == null ? AppTheme.textMuted : AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Time'),
                        _field(_timeController, 'e.g. 19:00'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _label('Soundcheck'),
              _field(_soundcheckController, 'e.g. 17:30'),
              const SizedBox(height: 12),
              _label('Setting'),
              _field(_settingController, 'e.g. Indoor, Outdoor, Zelt...'),
              const SizedBox(height: 12),
              _label('Fee'),
              _field(_feeController, 'e.g. 500€'),
              const SizedBox(height: 12),
              _label('Organizer'),
              _field(_organizerController, 'e.g. Stadtgemeinde'),
              const SizedBox(height: 12),
              _label('Notes'),
              _field(_notesController, 'Any additional info...', maxLines: 3),
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
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
  );

  Widget _field(TextEditingController controller, String hint, {int maxLines = 1}) =>
    TextField(
      controller: controller,
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
    );
}