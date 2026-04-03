import 'package:flutter/material.dart';
import '../../core/services/logger_service.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';

/// A debug widget to display and export logs
/// Usage: Add to your Scaffold's body or overlay for debugging
/// In production, this should be hidden or accessible via long-press gesture
class ErrorLoggerWidget extends StatefulWidget {
  final bool alwaysShow;
  final VoidCallback? onExport;

  const ErrorLoggerWidget({
    super.key,
    this.alwaysShow = false,
    this.onExport,
  });

  @override
  State<ErrorLoggerWidget> createState() => _ErrorLoggerWidgetState();
}

class _ErrorLoggerWidgetState extends State<ErrorLoggerWidget> {
  bool _isExpanded = false;
  LogLevel _filterLevel = LogLevel.debug;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only show if expanded or alwaysShow is true
    if (!_isExpanded && !widget.alwaysShow) {
      return _buildFloatingButton(context);
    }

    return Material(
      color: Colors.black87,
      child: Column(
        children: [
          // Header
          _buildHeader(context),
          // Filter chips
          _buildFilterChips(),
          // Logs list
          Expanded(
            child: _buildLogsList(),
          ),
          // Actions
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    final errorCount = LoggerService.getLogsByLevel(LogLevel.error).length +
        LoggerService.getLogsByLevel(LogLevel.critical).length;

    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: errorCount > 0 ? Colors.red : Colors.blue,
        onPressed: () => setState(() => _isExpanded = true),
        child: Text(
          errorCount.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Debug Logs (${LoggerService.getLogs().length})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => setState(() => _isExpanded = false),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: LogLevel.values
            .map(
              (level) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: FilterChip(
                  label: Text(
                    level.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      color: _filterLevel == level ? Colors.white : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  selected: _filterLevel == level,
                  onSelected: (_) => setState(() => _filterLevel = level),
                  backgroundColor: Colors.grey[800],
                  selectedColor: _getLevelColor(level),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildLogsList() {
    final logs = LoggerService.getRecentLogs(count: 100)
        .where((log) => log.level.index >= _filterLevel.index)
        .toList();

    if (logs.isEmpty) {
      return Center(
        child: Text(
          'No logs',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return _LogEntryTile(log: log);
      },
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy Logs'),
            onPressed: () => _copyLogs(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Clear'),
            onPressed: () {
              LoggerService.clearLogs();
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.info, size: 16),
            label: const Text('Stats'),
            onPressed: () => _showStats(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _copyLogs() {
    final logsText = LoggerService.exportLogs(minLevel: _filterLevel);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logs copied to clipboard (${logsText.length} chars)'),
        duration: const Duration(seconds: 2),
      ),
    );
    widget.onExport?.call();
  }

  void _showStats() {
    final stats = LoggerService.getLogStats();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: stats.entries
              .map((e) => Text('${e.key}: ${e.value}'))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.critical:
        return Colors.red[900]!;
    }
  }
}

/// Individual log entry tile
class _LogEntryTile extends StatefulWidget {
  final LogEntry log;

  const _LogEntryTile({required this.log});

  @override
  State<_LogEntryTile> createState() => _LogEntryTileState();
}

class _LogEntryTileState extends State<_LogEntryTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          leading: _buildLevelIcon(),
          title: Text(
            widget.log.message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            widget.log.timestamp.toString(),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
          ),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
        ),
        if (_isExpanded) _buildExpandedContent(),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }

  Widget _buildLevelIcon() {
    IconData icon;
    Color color;

    switch (widget.log.level) {
      case LogLevel.debug:
        icon = Icons.bug_report;
        color = Colors.grey;
        break;
      case LogLevel.info:
        icon = Icons.info;
        color = Colors.blue;
        break;
      case LogLevel.warning:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case LogLevel.error:
        icon = Icons.error;
        color = Colors.red;
        break;
      case LogLevel.critical:
        icon = Icons.cancel;
        color = Colors.red[900]!;
        break;
    }

    return Icon(icon, color: color, size: 16);
  }

  Widget _buildExpandedContent() {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.log.exception != null)
            Text(
              'Exception: ${widget.log.exception}',
              style: TextStyle(
                color: Colors.red[300],
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          if (widget.log.stackTrace != null)
            Text(
              'Stack: ${widget.log.stackTrace.toString().split('\n').first}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
        ],
      ),
    );
  }
}

/// Show all log files available
class LogFilesViewerWidget extends StatefulWidget {
  const LogFilesViewerWidget({super.key});

  @override
  State<LogFilesViewerWidget> createState() => _LogFilesViewerWidgetState();
}

class _LogFilesViewerWidgetState extends State<LogFilesViewerWidget> {
  late Future<List<File>> _logFiles;

  @override
  void initState() {
    super.initState();
    _logFiles = FileLoggerService.getAllLogFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Column(
        children: [
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Log Files',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<File>>(
              future: _logFiles,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No log files',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final file = snapshot.data![index];
                    final name = file.path.split('/').last;
                    final size = (file.lengthSync() / 1024).toStringAsFixed(2);

                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.description, color: Colors.blue),
                      title: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      subtitle: Text(
                        '$size KB · ${file.lastModifiedSync()}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                        ),
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const Text('View'),
                            onTap: () => _viewFile(file),
                          ),
                          PopupMenuItem(
                            child: const Text('Copy Path'),
                            onTap: () => _copyToClipboard(file.path),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('Summary'),
                  onPressed: _showSummary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.folder, size: 16),
                  label: const Text('Open Folder'),
                  onPressed: _openLogsFolder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _viewFile(File file) {
    final content = file.readAsStringSync();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(file.path.split('/').last),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _copyToClipboard(content),
            child: const Text('Copy Content'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    // Note: Requires flutter/services
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied (${(text.length / 1024).toStringAsFixed(2)} KB)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showSummary() async {
    final summary = await FileLoggerService.getLogsSummary();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logs Summary'),
        content: SingleChildScrollView(
          child: Text(
            summary,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _copyToClipboard(summary),
            child: const Text('Copy Summary'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _openLogsFolder() async {
    final path = await FileLoggerService.getLogsDirPath();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logs saved to: $path'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
