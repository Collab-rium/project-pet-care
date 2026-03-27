import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/api_provider.dart';

/// Screen for adding or editing a reminder
class AddReminderScreen extends StatefulWidget {
  final List<Pet> pets;
  final Reminder? reminder; // If provided, we're editing

  const AddReminderScreen({
    super.key,
    required this.pets,
    this.reminder,
  });

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  String? _selectedPetId;
  String _selectedType = 'feeding';
  String _selectedRepeat = 'none';
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.reminder?.message ?? '');
    _notesController = TextEditingController(); // Notes not used in backend
    _selectedPetId = widget.reminder?.petId ?? widget.pets.firstOrNull?.id;
    _selectedType = widget.reminder?.type ?? 'feeding';
    _selectedRepeat = widget.reminder?.repeat ?? 'none';

    if (widget.reminder != null) {
      // Parse scheduledTime (ISO 8601 format)
      try {
        final dt = DateTime.parse(widget.reminder!.scheduledTime);
        _scheduledDate = dt;
        _scheduledTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      setState(() {
        _scheduledDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _scheduledTime = time;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPetId == null) {
      setState(() {
        _errorMessage = 'Please select a pet';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final api = ApiProvider.getApiService(authService: authService);

      // Combine date and time into ISO 8601 scheduledTime
      DateTime? scheduledDateTime;
      if (_scheduledDate != null) {
        final time = _scheduledTime ?? TimeOfDay.now();
        scheduledDateTime = DateTime(
          _scheduledDate!.year,
          _scheduledDate!.month,
          _scheduledDate!.day,
          time.hour,
          time.minute,
        );
      }

      final reminderData = {
        'message': _titleController.text.trim(),
        'petId': _selectedPetId,
        'type': _selectedType,
        'repeat': _selectedRepeat,
        if (scheduledDateTime != null)
          'scheduledTime': scheduledDateTime.toIso8601String(),
      };

      if (_isEditing) {
        await api.updateReminder(widget.reminder!.id, reminderData);
      } else {
        await api.createReminder(reminderData);
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Signal refresh needed
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Reminder' : 'Add Reminder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Pet dropdown
              DropdownButtonFormField<String>(
                value: _selectedPetId,
                decoration: const InputDecoration(
                  labelText: 'Pet *',
                  prefixIcon: Icon(Icons.pets),
                  border: OutlineInputBorder(),
                ),
                items: widget.pets.map((pet) {
                  return DropdownMenuItem(
                    value: pet.id,
                    child: Text(pet.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPetId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a pet';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Title field
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.trim().length > 100) {
                    return 'Title must be 100 characters or less';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type *',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: Reminder.validTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.replaceAll('_', ' ')),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Scheduled Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _scheduledDate != null
                            ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                            : 'Select date',
                        style: TextStyle(
                          color: _scheduledDate != null ? null : Colors.grey[600],
                        ),
                      ),
                      if (_scheduledDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _scheduledDate = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time picker
              InkWell(
                onTap: _selectTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Scheduled Time',
                    prefixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _scheduledTime != null
                            ? '${_scheduledTime!.hour.toString().padLeft(2, '0')}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
                            : 'Select time',
                        style: TextStyle(
                          color: _scheduledTime != null ? null : Colors.grey[600],
                        ),
                      ),
                      if (_scheduledTime != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _scheduledTime = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Repeat dropdown
              DropdownButtonFormField<String>(
                value: _selectedRepeat,
                decoration: const InputDecoration(
                  labelText: 'Repeat',
                  prefixIcon: Icon(Icons.repeat),
                  border: OutlineInputBorder(),
                ),
                items: Reminder.validRepeats.map((repeat) {
                  return DropdownMenuItem(
                    value: repeat,
                    child: Text(repeat == 'none' ? 'No repeat' : repeat),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRepeat = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Notes field
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              FilledButton(
                onPressed: _isLoading ? null : _saveReminder,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isEditing ? 'Update Reminder' : 'Add Reminder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
