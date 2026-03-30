import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/utils/error_handler.dart';
import '../models/models.dart';

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
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    
    // Mock tasks - in real app would load from local storage
    await Future.delayed(const Duration(milliseconds: 300));
    
    final now = DateTime.now();
    _tasks = [
      Task(
        id: 'task-1',
        petId: 'pet-1',
        userId: 'user-1',
        type: 'feeding',
        title: 'Feed Bella breakfast',
        description: 'Premium kibble with vitamins',
        scheduledTime: now.subtract(const Duration(hours: 2)),
        status: 'completed',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Task(
        id: 'task-2',
        petId: 'pet-1',
        userId: 'user-1',
        type: 'medication',
        title: 'Give flea treatment',
        description: 'Monthly flea and tick prevention',
        scheduledTime: now.add(const Duration(hours: 3)),
        status: 'pending',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Task(
        id: 'task-3',
        petId: 'pet-2',
        userId: 'user-1',
        type: 'grooming',
        title: 'Brush Max\'s coat',
        description: 'Use de-shedding tool',
        scheduledTime: now.subtract(const Duration(hours: 5)),
        status: 'pending',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
    
    setState(() => _isLoading = false);
  }

  List<Task> get _filteredTasks {
    if (widget.filter == null) return _tasks;
    
    final now = DateTime.now();
    switch (widget.filter) {
      case 'completed':
        return _tasks.where((t) => t.status == 'completed').toList();
      case 'pending':
        return _tasks.where((t) => t.status == 'pending' && t.scheduledTime.isAfter(now)).toList();
      case 'overdue':
        return _tasks.where((t) => t.status == 'pending' && t.scheduledTime.isBefore(now)).toList();
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
      final newTask = Task(
        id: 'task-${DateTime.now().millisecondsSinceEpoch}',
        petId: result['petId'] ?? 'pet-1',
        userId: 'user-1',
        type: result['type'],
        title: result['title'],
        description: result['description'],
        scheduledTime: result['scheduledTime'],
        status: 'pending',
        createdAt: DateTime.now(),
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

  void _toggleTaskStatus(Task task) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = Task(
          id: task.id,
          petId: task.petId,
          userId: task.userId,
          type: task.type,
          title: task.title,
          description: task.description,
          scheduledTime: task.scheduledTime,
          status: task.status == 'completed' ? 'pending' : 'completed',
          createdAt: task.createdAt,
          completedAt: task.status != 'completed' ? DateTime.now() : null,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_title, style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
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
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
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

  const _TaskItem({
    required this.task,
    required this.onToggle,
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
    if (task.isOverdue) return AppColors.error;
    if (task.status == 'completed') return AppColors.success;
    return AppColors.info;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final isCompleted = task.status == 'completed';

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: isCompleted,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.primary,
            ),
            
            const SizedBox(width: 8),
            
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
                    task.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (task.description?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        task.description!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, h:mm a').format(task.scheduledTime),
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
            ),
            
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.textTertiary,
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
              // Task type
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Task Type',
                  border: OutlineInputBorder(),
                ),
                items: _taskTypes.map((type) {
                  return DropdownMenuItem(
                    value: type['value'],
                    child: Row(
                      children: [
                        Icon(type['icon'], size: 20),
                        const SizedBox(width: 8),
                        Text(type['label']),
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
