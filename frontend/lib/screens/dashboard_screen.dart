import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../core/services/logger_service.dart';
import '../core/services/file_logger_service.dart';

/// Dashboard screen showing tasks with full task management
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _filter = 'all'; // all, pending, completed, overdue

  @override
  void initState() {
    super.initState();
    LoggerService.info('DashboardScreen: Screen opened');
    FileLoggerService.log('DashboardScreen: Screen initialized');
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      LoggerService.info('DashboardScreen: Loading tasks...');
      setState(() => _isLoading = true);

      await Future.delayed(const Duration(milliseconds: 300));

      final now = DateTime.now();
    _tasks = [
      Task(
        id: 'task-1',
        petId: 'pet-1',
        petName: 'Bella',
        type: 'feeding',
        message: 'Feed Bella breakfast',
        scheduledTime: now.subtract(const Duration(hours: 2)).toIso8601String(),
        status: 'completed',
        isOverdue: false,
        repeat: 'daily',
      ),
      Task(
        id: 'task-2',
        petId: 'pet-1',
        petName: 'Bella',
        type: 'medication',
        message: 'Give flea treatment',
        scheduledTime: now.add(const Duration(hours: 3)).toIso8601String(),
        status: 'pending',
        isOverdue: false,
        repeat: 'monthly',
      ),
      Task(
        id: 'task-3',
        petId: 'pet-2',
        petName: 'Max',
        type: 'grooming',
        message: 'Brush Max\'s coat',
        scheduledTime: now.subtract(const Duration(hours: 5)).toIso8601String(),
        status: 'pending',
        isOverdue: true,
        repeat: 'weekly',
      ),
      Task(
        id: 'task-4',
        petId: 'pet-2',
        petName: 'Max',
        type: 'exercise',
        message: 'Take Max for walk',
        scheduledTime: now.add(const Duration(hours: 1)).toIso8601String(),
        status: 'pending',
        isOverdue: false,
        repeat: 'daily',
      ),
      Task(
        id: 'task-5',
        petId: 'pet-1',
        petName: 'Bella',
        type: 'vet_visit',
        message: 'Vet appointment next week',
        scheduledTime: now.add(const Duration(days: 7)).toIso8601String(),
        status: 'pending',
        isOverdue: false,
        repeat: 'none',
      ),
    ];

    LoggerService.info('DashboardScreen: Loaded ${_tasks.length} tasks');
    await FileLoggerService.log('DashboardScreen: Loaded ${_tasks.length} tasks');
    setState(() => _isLoading = false);
    } catch (e, st) {
      LoggerService.error('DashboardScreen: Failed to load tasks - $e', exception: e);
      await FileLoggerService.logError('DashboardScreen load failed', exception: e, stackTrace: st);
      setState(() => _isLoading = false);
    }
  }

  List<Task> get _filteredTasks {
    var tasks = List<Task>.from(_tasks);

    switch (_filter) {
      case 'pending':
        tasks =
            tasks.where((t) => t.status == 'pending' && !t.isOverdue).toList();
        break;
      case 'completed':
        tasks = tasks.where((t) => t.status == 'completed').toList();
        break;
      case 'overdue':
        tasks = tasks.where((t) => t.isOverdue).toList();
        break;
      default:
        // All tasks - show pending and overdue first, then completed
        tasks.sort((a, b) {
          if (a.status == 'completed' && b.status != 'completed') return 1;
          if (a.status != 'completed' && b.status == 'completed') return -1;
          return 0;
        });
    }

    return tasks;
  }

  int get _completedCount =>
      _tasks.where((t) => t.status == 'completed').length;
  int get _pendingCount =>
      _tasks.where((t) => t.status == 'pending' && !t.isOverdue).length;
  int get _overdueCount => _tasks.where((t) => t.isOverdue).length;

  Future<void> _addTask() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddTaskDialog(),
    );

    if (result != null) {
      final now = DateTime.now();
      final schedTime = result['scheduledTime'] as DateTime;

      final newTask = Task(
        id: 'task-${DateTime.now().millisecondsSinceEpoch}',
        petId: result['petId'] ?? 'pet-1',
        petName: result['petName'] ?? 'Pet',
        type: result['type'],
        message: result['title'],
        scheduledTime: schedTime.toIso8601String(),
        status: 'pending',
        isOverdue: schedTime.isBefore(now),
        repeat: 'none',
      );

      setState(() {
        _tasks.add(newTask);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task added!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  Future<void> _editTask(Task task) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _EditTaskDialog(task: task),
    );

    if (result != null) {
      final now = DateTime.now();
      final schedTime = result['scheduledTime'] as DateTime;

      setState(() {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = Task(
            id: task.id,
            petId: result['petId'] ?? task.petId,
            petName: result['petName'] ?? task.petName,
            type: result['type'],
            message: result['title'],
            scheduledTime: schedTime.toIso8601String(),
            status: task.status,
            isOverdue: schedTime.isBefore(now) && task.status != 'completed',
            repeat: task.repeat,
          );
        }
      });
    }
  }

  void _deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.message}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _tasks.removeWhere((t) => t.id == task.id);
              });
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _toggleTaskStatus(Task task) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = Task(
          id: task.id,
          petId: task.petId,
          petName: task.petName,
          type: task.type,
          message: task.message,
          scheduledTime: task.scheduledTime,
          status: task.status == 'completed' ? 'pending' : 'completed',
          isOverdue: task.isOverdue && task.status == 'completed'
              ? false
              : task.isOverdue,
          repeat: task.repeat,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final userName = authService.currentUser?.name ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTasks,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $userName! 👋',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getGreetingSubtitle(),
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),

                    // Summary cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              icon: Icons.check_circle,
                              label: 'Completed',
                              value: _completedCount.toString(),
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              icon: Icons.pending,
                              label: 'Pending',
                              value: _pendingCount.toString(),
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              icon: Icons.warning,
                              label: 'Overdue',
                              value: _overdueCount.toString(),
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            isSelected: _filter == 'all',
                            onSelected: () => setState(() => _filter = 'all'),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Pending',
                            isSelected: _filter == 'pending',
                            onSelected: () =>
                                setState(() => _filter = 'pending'),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Completed',
                            isSelected: _filter == 'completed',
                            onSelected: () =>
                                setState(() => _filter = 'completed'),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Overdue',
                            isSelected: _filter == 'overdue',
                            onSelected: () =>
                                setState(() => _filter = 'overdue'),
                          ),
                          if (_filter != 'all') ...[
                            const SizedBox(width: 8),
                            ActionChip(
                              avatar: const Icon(Icons.clear, size: 16),
                              label: const Text('Reset'),
                              onPressed: () => setState(() => _filter = 'all'),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tasks section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tasks',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton.icon(
                            onPressed: _addTask,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add'),
                          ),
                        ],
                      ),
                    ),

                    // Task list
                    if (_filteredTasks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                _filter == 'completed'
                                    ? Icons.check_circle_outline
                                    : Icons.task_alt,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _filter == 'all'
                                    ? 'No tasks yet'
                                    : 'No $_filter tasks',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              if (_filter == 'all') ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Tap + to add your first task',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = _filteredTasks[index];
                          return _TaskCard(
                            task: task,
                            onToggle: () => _toggleTaskStatus(task),
                            onEdit: () => _editTask(task),
                            onDelete: () => _deleteTask(task),
                          );
                        },
                      ),

                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  String _getGreetingSubtitle() {
    final total = _tasks.length;
    if (total == 0) {
      return 'No tasks yet. Tap + to add one!';
    }
    if (_overdueCount > 0) {
      return 'You have $_overdueCount overdue task${_overdueCount > 1 ? 's' : ''}';
    }
    if (_pendingCount > 0) {
      return 'You have $_pendingCount task${_pendingCount > 1 ? 's' : ''} remaining';
    }
    return 'All tasks completed! Great job! 🎉';
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getTaskIcon() {
    switch (task.type.toLowerCase()) {
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
      default:
        return Icons.event;
    }
  }

  Color _getStatusColor(BuildContext context) {
    if (task.isOverdue) return Colors.red;
    if (task.status == 'completed') return Colors.green;
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(context);
    final isCompleted = task.status == 'completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isCompleted,
                  onChanged: (_) => onToggle(),
                  activeColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getTaskIcon(), color: color, size: 20),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.message,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        decorationThickness: 2.5,
                        color: isCompleted
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (task.petName?.isNotEmpty ?? false) ...[
                          Icon(Icons.pets,
                              size: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            task.petName!,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Icon(Icons.access_time, size: 12, color: color),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            DateFormat('MMM d, h:mm a')
                                .format(DateTime.parse(task.scheduledTime)),
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status badge
              if (task.isOverdue)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'OVERDUE',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (isCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                onPressed: onDelete,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTaskDialog extends StatefulWidget {
  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  String _selectedType = 'feeding';
  DateTime _scheduledTime = DateTime.now().add(const Duration(hours: 1));

  final List<Map<String, dynamic>> _taskTypes = [
    {'value': 'feeding', 'label': 'Feeding', 'icon': Icons.restaurant},
    {'value': 'medication', 'label': 'Medication', 'icon': Icons.medication},
    {'value': 'grooming', 'label': 'Grooming', 'icon': Icons.content_cut},
    {'value': 'exercise', 'label': 'Exercise', 'icon': Icons.directions_run},
    {'value': 'vet_visit', 'label': 'Vet Visit', 'icon': Icons.local_hospital},
    {'value': 'vaccination', 'label': 'Vaccination', 'icon': Icons.vaccines},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Task Type',
                  border: OutlineInputBorder(),
                ),
                items: _taskTypes.map<DropdownMenuItem<String>>((type) {
                  return DropdownMenuItem<String>(
                    value: type['value'] as String,
                    child: Row(
                      children: [
                        Icon(type['icon'] as IconData, size: 20),
                        const SizedBox(width: 8),
                        Text(type['label'] as String),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedType = value!);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Feed Bella breakfast',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date & Time'),
                subtitle: Text(
                    DateFormat('MMM d, yyyy h:mm a').format(_scheduledTime)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _scheduledTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );

                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_scheduledTime),
                    );

                    if (time != null) {
                      setState(() {
                        _scheduledTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'type': _selectedType,
                'title': _titleController.text,
                'scheduledTime': _scheduledTime,
              });
            }
          },
          child: const Text('Add Task'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

class _EditTaskDialog extends StatefulWidget {
  final Task task;

  const _EditTaskDialog({required this.task});

  @override
  _EditTaskDialogState createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<_EditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;

  late String _selectedType;
  late DateTime _scheduledTime;

  final List<Map<String, dynamic>> _taskTypes = [
    {'value': 'feeding', 'label': 'Feeding', 'icon': Icons.restaurant},
    {'value': 'medication', 'label': 'Medication', 'icon': Icons.medication},
    {'value': 'grooming', 'label': 'Grooming', 'icon': Icons.content_cut},
    {'value': 'exercise', 'label': 'Exercise', 'icon': Icons.directions_run},
    {'value': 'vet_visit', 'label': 'Vet Visit', 'icon': Icons.local_hospital},
    {'value': 'vaccination', 'label': 'Vaccination', 'icon': Icons.vaccines},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.message);
    _selectedType = widget.task.type;
    _scheduledTime = DateTime.parse(widget.task.scheduledTime);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Task Type',
                  border: OutlineInputBorder(),
                ),
                items: _taskTypes.map<DropdownMenuItem<String>>((type) {
                  return DropdownMenuItem<String>(
                    value: type['value'] as String,
                    child: Row(
                      children: [
                        Icon(type['icon'] as IconData, size: 20),
                        const SizedBox(width: 8),
                        Text(type['label'] as String),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedType = value!);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date & Time'),
                subtitle: Text(
                    DateFormat('MMM d, yyyy h:mm a').format(_scheduledTime)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _scheduledTime,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );

                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_scheduledTime),
                    );

                    if (time != null) {
                      setState(() {
                        _scheduledTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'type': _selectedType,
                'title': _titleController.text,
                'scheduledTime': _scheduledTime,
              });
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
