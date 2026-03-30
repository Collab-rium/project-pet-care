import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/api_provider.dart';

/// Dashboard screen showing today's tasks and summary
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardData? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use mock data since we're local-only
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _dashboardData = DashboardData(
          date: DateTime.now().toIso8601String(),
          tasks: [],
          summary: DashboardSummary(
            total: 3,
            completed: 2,
            pending: 2,
            overdue: 1,
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
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
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: _buildBody(userName),
      ),
    );
  }

  Widget _buildBody(String userName) {
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
              onPressed: _loadDashboard,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final data = _dashboardData;
    if (data == null) {
      return const Center(child: Text('No data'));
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            'Hello, $userName! 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _getGreetingSubtitle(data),
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Summary cards
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/tasks', arguments: 'completed');
                  },
                  child: _SummaryCard(
                    icon: Icons.check_circle,
                    label: 'Completed',
                    value: data.summary.completed.toString(),
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/tasks', arguments: 'pending');
                  },
                  child: _SummaryCard(
                    icon: Icons.pending,
                    label: 'Pending',
                    value: data.summary.pending.toString(),
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/tasks', arguments: 'overdue');
                  },
                  child: _SummaryCard(
                    icon: Icons.warning,
                    label: 'Overdue',
                    value: data.summary.overdue.toString(),
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Today's tasks
          Text(
            "Today's Tasks",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          if (data.tasks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.green[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks for today!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enjoy your day 🎉',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          else
            ...data.tasks.map((task) => _TaskCard(task: task)),
        ],
      ),
    );
  }

  String _getGreetingSubtitle(DashboardData data) {
    final total = data.summary.completed + data.summary.pending + data.summary.overdue;
    if (total == 0) {
      return 'No tasks scheduled for today';
    }
    if (data.summary.overdue > 0) {
      return 'You have ${data.summary.overdue} overdue task${data.summary.overdue > 1 ? 's' : ''}';
    }
    if (data.summary.pending > 0) {
      return 'You have ${data.summary.pending} task${data.summary.pending > 1 ? 's' : ''} remaining today';
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
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

  const _TaskCard({required this.task});

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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getTaskIcon(), color: color),
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
                          task.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    decoration: task.status == 'completed'
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                        ),
                      ),
                      if (task.isOverdue)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'OVERDUE',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.petName ?? 'Unknown Pet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (task.scheduledTimeOnly != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.scheduledTimeOnly!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
