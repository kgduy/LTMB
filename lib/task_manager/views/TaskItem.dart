import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tasks.dart';
import '../dtb/databasehelper.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final Function(Task) onEdit;
  final Function(Task) onDelete;
  final Function(Task) onTap;  // Thêm onTap để nhận sự kiện bấm vào công việc

  const TaskItem({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,  // Nhận thêm đối số onTap
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  final DBHelper _dbHelper = DBHelper();
  String? _assignedToName;

  @override
  void initState() {
    super.initState();
    _loadAssignedUser();
  }

  Future<void> _loadAssignedUser() async {
    if (widget.task.assignedTo != null) {
      final name = await _dbHelper.getUsernameById(widget.task.assignedTo!);
      setState(() {
        _assignedToName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      child: GestureDetector(  // Thêm GestureDetector để bắt sự kiện bấm
        onTap: () => widget.onTap(task),  // Gọi onTap khi bấm vào công việc
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          title: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text('Trạng thái: ${task.status}'),
              if (task.dueDate != null)
                Text('Hạn chót: ${DateFormat('dd/MM/yyyy').format(task.dueDate!)}'),
              Text('Ưu tiên: ${_getPriorityLabel(task.priority)}'),
              if (task.category != null && task.category!.isNotEmpty)
                Text('Danh mục: ${task.category}'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => widget.onEdit(task),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await _confirmDelete(context);
                  if (confirm) {
                    widget.onDelete(task);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận xoá'),
        content: Text('Bạn có chắc chắn muốn xoá công việc này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Huỷ'),
          ),
          TextButton(
            onPressed: () async {
              await widget.onDelete(widget.task);
              Navigator.of(ctx).pop(true);
            },
            child: Text('Xoá', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  String _getPriorityLabel(int priority) {
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
}