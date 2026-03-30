import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/utils/error_handler.dart';

/// Dashboard screen showing today's tasks with full task management
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);

    // Mock tasks for demo
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
    ];

    setState(() => _isLoading = false);
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

      AppErrorHandler.showSuccessSnackBar(
        context,
        'Task added successfully!',
      );
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

      AppErrorHandler.showSuccessSnackBar(
        context,
        'Task updated successfully!',
      );
    }
  }

  void _deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.message}"?'),
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
              AppErrorHandler.showSuccessSnackBar(
                context,
                'Task deleted',
              );
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
          isOverdue: task.isOverdue,
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Text(
                      'Hello, $userName! 👋',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getGreetingSubtitle(),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    // Summary cards
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/tasks',
                                  arguments: 'completed');
                            },
                            child: _SummaryCard(
                              icon: Icons.check_circle,
                              label: 'Completed',
                              value: _completedCount.toString(),
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/tasks',
                                  arguments: 'pending');
                            },
                            child: _SummaryCard(
                              icon: Icons.pending,
                              label: 'Pending',
                              value: _pendingCount.toString(),
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/tasks',
                                  arguments: 'overdue');
                            },
                            child: _SummaryCard(
                              icon: Icons.warning,
                              label: 'Overdue',
                              value: _overdueCount.toString(),
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick actions
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.add_task,
                            label: 'Add Task',
                            onTap: _addTask,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.pets,
                            label: 'My Pets',
                            onTap: () => Navigator.pushNamed(context, '/pets'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.account_balance_wallet,
                            label: 'Budget',
                            onTap: () =>
                                Navigator.pushNamed(context, '/budget'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Today's tasks
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Tasks",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
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
                    const SizedBox(height: 16),

                    if (_tasks.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks for today!',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to add your first task',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._tasks.map((task) => _TaskCard(
                            task: task,
                            onToggle: () => _toggleTaskStatus(task),
                            onEdit: () => _editTask(task),
                            onDelete: () => _deleteTask(task),
                          )),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _getGreetingSubtitle() {
    final total = _tasks.length;
    if (total == 0) {
      return 'No tasks scheduled for today';
    }
    if (_overdueCount > 0) {
      return 'You have $_overdueCount overdue task${_overdueCount > 1 ? 's' : ''}';
    }
    if (_pendingCount > 0) {
      return 'You have $_pendingCount task${_pendingCount > 1 ? 's' : ''} remaining today';
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
                color: Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
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

  Color _getStatusColor() {
    if (task.isOverdue) return Colors.red;
    if (task.status == 'completed') return Colors.green;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final isCompleted = task.status == 'completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: isCompleted,
              onChanged: (_) => onToggle(),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getTaskIcon(), color: color, size: 20),
            ),
          ],
        ),
        title: Text(
          task.message,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.petName?.isNotEmpty ?? false)
              Text(
                'Pet: ${task.petName}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: color),
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
                if (task.isOverdue)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'OVERDUE',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: Colors.grey[500],
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.red[400],
              onPressed: onDelete,
            ),
          ],
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
  final _descriptionController = TextEditingController();

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
                  labelText: 'Title',
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
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  DateFormat('MMM d, yyyy h:mm a').format(_scheduledTime),
                ),
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
                'description': _descriptionController.text,
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
    _descriptionController.dispose();
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
  late TextEditingController _descriptionController;

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
    _descriptionController = TextEditingController();
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
                  labelText: 'Title',
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
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  DateFormat('MMM d, yyyy h:mm a').format(_scheduledTime),
                ),
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
                'description': _descriptionController.text,
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
    _descriptionController.dispose();
    super.dispose();
  }
}
