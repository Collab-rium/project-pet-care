import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/api_provider.dart';
import '../core/services/logger_service.dart';
import '../core/services/file_logger_service.dart';

/// Screen for adding or editing a pet
class AddPetScreen extends StatefulWidget {
  final Pet? pet; // If provided, we're editing

  const AddPetScreen({super.key, this.pet});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _weightController;
  late TextEditingController _notesController;
  String _selectedType = 'dog';
  DateTime? _birthDate;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing => widget.pet != null;

  @override
  void initState() {
    super.initState();
    LoggerService.info('AddPetScreen: Screen opened (${_isEditing ? 'editing' : 'creating'})');
    FileLoggerService.log('AddPetScreen: Screen initialized');
    _nameController = TextEditingController(text: widget.pet?.name ?? '');
    _breedController = TextEditingController(text: widget.pet?.breed ?? '');
    _weightController = TextEditingController(
      text: widget.pet?.weight?.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.pet?.notes ?? '');
    _selectedType = widget.pet?.type ?? 'dog';
    if (widget.pet?.birthDate != null) {
      _birthDate = DateTime.tryParse(widget.pet!.birthDate!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _birthDate = date;
      });
    }
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      LoggerService.info('AddPetScreen: Saving pet (${_isEditing ? 'update' : 'create'})...');
      final authService = context.read<AuthService>();
      final api = ApiProvider.getApiService(authService: authService);

      final petData = {
        'name': _nameController.text.trim(),
        'type': _selectedType,
        if (_breedController.text.trim().isNotEmpty)
          'breed': _breedController.text.trim(),
        if (_birthDate != null) 'birthDate': _birthDate!.toIso8601String(),
        if (_weightController.text.trim().isNotEmpty)
          'weight': double.tryParse(_weightController.text.trim()),
        if (_notesController.text.trim().isNotEmpty)
          'notes': _notesController.text.trim(),
      };

      if (_isEditing) {
        await api.updatePet(widget.pet!.id, petData);
        LoggerService.info('AddPetScreen: Pet updated successfully');
        await FileLoggerService.log('AddPetScreen: Pet updated');
      } else {
        await api.createPet(petData);
        LoggerService.info('AddPetScreen: Pet created successfully');
        await FileLoggerService.log('AddPetScreen: Pet created');
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Signal refresh needed
      }
    } catch (e, st) {
      LoggerService.error('AddPetScreen: Save failed - $e', exception: e);
      await FileLoggerService.logError('AddPetScreen save failed', exception: e, stackTrace: st);
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
        title: Text(_isEditing ? 'Edit Pet' : 'Add Pet'),
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

              // Name field
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Pet Name *',
                  prefixIcon: Icon(Icons.pets),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your pet\'s name';
                  }
                  if (value.trim().length > 100) {
                    return 'Name must be 100 characters or less';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Pet Type *',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: Pet.validTypes.map((type) {
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

              // Breed field
              TextFormField(
                controller: _breedController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Breed (optional)',
                  prefixIcon: Icon(Icons.info_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Birth date picker
              InkWell(
                onTap: _selectBirthDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Birth Date (optional)',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _birthDate != null
                            ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                            : 'Select date',
                        style: TextStyle(
                          color:
                              _birthDate != null ? null : Colors.grey[600],
                        ),
                      ),
                      if (_birthDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _birthDate = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Weight field
              TextFormField(
                controller: _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Weight in kg (optional)',
                  prefixIcon: Icon(Icons.monitor_weight),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final weight = double.tryParse(value);
                    if (weight == null || weight <= 0) {
                      return 'Please enter a valid weight';
                    }
                  }
                  return null;
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
                onPressed: _isLoading ? null : _savePet,
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
                    : Text(_isEditing ? 'Update Pet' : 'Add Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
