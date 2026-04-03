import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/api_provider.dart';
import 'add_reminder_screen.dart';
import '../core/services/logger_service.dart';
import '../core/services/file_logger_service.dart';

/// Screen showing list of reminders
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Reminder> _reminders = [];
  List<Pet> _pets = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedPetId;

  @override
  void initState() {
    super.initState();
    LoggerService.info('RemindersScreen: Screen opened');
    FileLoggerService.log('RemindersScreen: Screen initialized');
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      LoggerService.info('RemindersScreen: Loading reminders...');
      final authService = context.read<AuthService>();
      final api = ApiProvider.getApiService(authService: authService);

      final pets = await api.getPets();
      final reminders = await api.getReminders(petId: _selectedPetId);

      LoggerService.info('RemindersScreen: Loaded ${reminders.length} reminders');
      await FileLoggerService.log('RemindersScreen: Loaded ${reminders.length} reminders');
      setState(() {
        _pets = pets;
        _reminders = reminders;
        _isLoading = false;
      });
    } catch (e, st) {
      LoggerService.error('RemindersScreen: Load failed - $e', exception: e);
      await FileLoggerService.logError('RemindersScreen load failed', exception: e, stackTrace: st);
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _getPetName(String petId) {
    final pet = _pets.firstWhere(
      (p) => p.id == petId,
      orElse: () => Pet(id: '', name: 'Unknown', type: '', ownerId: '', createdAt: ''),
    );
    return pet.name;
  }

  IconData _getReminderIcon(String type) {
    switch (type.toLowerCase()) {
      case 'feeding':
        return Icons.restaurant;
      case 'medication':
        return Icons.medication;
      case 'vaccination':
        return Icons.vaccines;
      case 'grooming':
        return Icons.content_cut;
      case 'vet_visit':
        return Icons.local_hospital;
      case 'exercise':
        return Icons.directions_run;
      case 'custom':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  Color _getReminderColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'snoozed':
        return Colors.orange;
      case 'skipped':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter by pet
          if (_pets.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Pets'),
                      selected: _selectedPetId == null,
                      onSelected: (_) {
                        setState(() {
                          _selectedPetId = null;
                        });
                        _loadData();
                      },
                    ),
                    const SizedBox(width: 8),
                    ..._pets.map((pet) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(pet.name),
                            selected: _selectedPetId == pet.id,
                            onSelected: (_) {
                              setState(() {
                                _selectedPetId = pet.id;
                              });
                              _loadData();
                            },
                          ),
                        )),
                  ],
                ),
              ),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => AddReminderScreen(pets: _pets),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No reminders yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to add a reminder',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          return _ReminderCard(
            reminder: reminder,
            petName: _getPetName(reminder.petId),
            icon: _getReminderIcon(reminder.type),
            statusColor: _getReminderColor(reminder.status),
            onTap: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => AddReminderScreen(
                    pets: _pets,
                    reminder: reminder,
                  ),
                ),
              );
              if (result == true) {
                _loadData();
              }
            },
            onDelete: () => _deleteReminder(reminder),
          );
        },
      ),
    );
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text(
          'Are you sure you want to delete "${reminder.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final authService = context.read<AuthService>();
      final api = ApiProvider.getApiService(authService: authService);
      await api.deleteReminder(reminder.id);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final String petName;
  final IconData icon;
  final Color statusColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.reminder,
    required this.petName,
    required this.icon,
    required this.statusColor,
    required this.onTap,
    required this.onDelete,
  });

  String _formatDate(String? date) {
    if (date == null) return '';
    try {
      final d = DateTime.parse(date);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // Let onDelete handle the actual deletion
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: statusColor),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              reminder.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              reminder.status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        petName,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (reminder.scheduledDate != null) ...[
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(reminder.scheduledDate),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (reminder.scheduledTimeOnly != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              reminder.scheduledTimeOnly!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (reminder.repeat != 'none') ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.repeat,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              reminder.repeat,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
