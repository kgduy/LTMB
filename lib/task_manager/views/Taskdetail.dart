import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tasks.dart';
import '../dtb/databasehelper.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({required this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final DBHelper _dbHelper = DBHelper();
  late Task _task;

  String? _assignedToName;
  String? _createdByName;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _loadUsernames();
  }

  Future<void> _loadUsernames() async {
    final assignedName = _task.assignedTo != null
        ? await _dbHelper.getUsernameById(_task.assignedTo!)
        : null;
    final createdName = _task.createdBy != null
        ? await _dbHelper.getUsernameById(_task.createdBy!)
        : null;

    setState(() {
      _assignedToName = assignedName;
      _createdByName = createdName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final task = _task;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết công việc'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              task.title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Divider(),
            _buildDetailRow('Mô tả', task.description ?? 'Không có mô tả'),
            _buildDetailRow('Trạng thái', task.status),
            _buildDetailRow('Mức ưu tiên', _getPriorityString(task.priority)),
            _buildDetailRow(
              'Hạn chót',
              task.dueDate != null
                  ? DateFormat('dd/MM/yyyy').format(task.dueDate!)
                  : 'Chưa có hạn chót',
            ),
            _buildDetailRow('Người được giao', _assignedToName ?? 'Đang tải...'),
            _buildDetailRow('Người tạo', _createdByName ?? 'Đang tải...'),
            _buildDetailRow('Danh mục', task.category?.isNotEmpty == true ? task.category! : 'Không có'),
            ElevatedButton(
              onPressed: _updateStatus,
              child: Text('Cập nhật trạng thái'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(value),
        SizedBox(height: 12),
      ],
    );
  }

  Future<void> _updateStatus() async {
    String newStatus = _getNextStatus(_task.status);
    Task updatedTask = _task.copyWith(status: newStatus);
    await _dbHelper.updateTask(updatedTask);  // Cập nhật trạng thái trong DB
    setState(() {
      _task = updatedTask;  // Cập nhật giao diện với trạng thái mới
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Trạng thái công việc đã được cập nhật')),
    );
  }

  String _getPriorityString(int priority) {
    switch (priority) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Cao';
      default:
        return 'Không xác định';
    }
  }

  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'Chưa hoàn thành':
        return 'Đang xử lý';
      case 'Đang xử lý':
        return 'Đã hoàn thành';
      case 'Đã hoàn thành':
        return 'Chưa hoàn thành';
      default:
        return 'Chưa hoàn thành';
    }
  }
}