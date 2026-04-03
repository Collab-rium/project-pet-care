import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/utils/error_handler.dart';
import '../models/models.dart';
import '../core/services/logger_service.dart';
import '../core/services/file_logger_service.dart';

/// Screen to manage all tasks with add/remove functionality
class TasksScreen extends StatefulWidget {
  final String? filter; // 'completed', 'pending', 'overdue', or null for all

  const TasksScreen({super.key, this.filter});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> _tasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    LoggerService.info('TasksScreen: Screen opened (filter: ${widget.filter ?? 'all'})');
    FileLoggerService.log('TasksScreen: Screen initialized');
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      LoggerService.info('TasksScreen: Loading tasks...');
      setState(() => _isLoading = true);

      // Mock tasks - in real app would load from local storage
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
    ];

    LoggerService.info('TasksScreen: Loaded ${_tasks.length} tasks');
    await FileLoggerService.log('TasksScreen: Loaded ${_tasks.length} tasks');
    setState(() => _isLoading = false);
    } catch (e, st) {
      LoggerService.error('TasksScreen: Load failed - $e', exception: e);
      await FileLoggerService.logError('TasksScreen load failed', exception: e, stackTrace: st);
      setState(() => _isLoading = false);
    }
  }

  List<Task> get _filteredTasks {
    if (widget.filter == null) return _tasks;

    switch (widget.filter) {
      case 'completed':
        return _tasks.where((t) => t.status == 'completed').toList();
      case 'pending':
        return _tasks
            .where((t) => t.status == 'pending' && !t.isOverdue)
            .toList();
      case 'overdue':
        return _tasks.where((t) => t.isOverdue).toList();
      default:
        return _tasks;
    }
  }

  String get _title {
    if (widget.filter == null) return 'All Tasks';
    switch (widget.filter) {
      case 'completed':
        return 'Completed Tasks';
      case 'pending':
        return 'Pending Tasks';
      case 'overdue':
        return 'Overdue Tasks';
      default:
        return 'All Tasks';
    }
  }

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

  void _deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_title, style: AppTextStyles.h2),
        
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredTasks.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: AppSpacing.pageInsets,
                  itemCount: _filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = _filteredTasks[index];
                    return _TaskItem(
                      task: task,
                      onToggle: () => _toggleTaskStatus(task),
                      onDelete: () => _deleteTask(task),
                      onEdit: () => _editTask(task),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.filter == 'completed'
                ? Icons.check_circle_outline
                : Icons.event_busy,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            widget.filter == 'completed'
                ? 'No completed tasks'
                : widget.filter == 'overdue'
                    ? 'No overdue tasks!'
                    : 'No pending tasks',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 8),
          Text(
            widget.filter == null ? 'Tap + to add your first task' : '',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _TaskItem({
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
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
    if (task.isOverdue) return AppColors.error;
    if (task.status == 'completed') return AppColors.success;
    return AppColors.info;
  }

  @override
  Widget build(BuildContext context) {
    
    final color = _getStatusColor();
    final isCompleted = task.status == 'completed';

    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: isCompleted,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.primary,
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
          task.title,
          style: AppTextStyles.bodyLarge.copyWith(
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
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, h:mm a')
                      .format(DateTime.parse(task.scheduledTime)),
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (task.isOverdue)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'OVERDUE',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.error,
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
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.textTertiary,
              onPressed: onEdit,
              iconSize: 20,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.textTertiary,
              onPressed: onDelete,
              iconSize: 20,
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
              // Task type
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

              // Title
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

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Date & Time
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
              // Task type
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

              // Title
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

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Date & Time
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
