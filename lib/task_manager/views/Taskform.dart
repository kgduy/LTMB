import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../dtb/databasehelper.dart';
import '../models/tasks.dart';
import '../models/users.dart';

class TaskFormScreen extends StatefulWidget {
  final User currentUser;
  final Task? task;

  const TaskFormScreen({required this.currentUser, this.task});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;
  int _priority = 2;
  String _status = 'Chưa hoàn thành';
  String? _assignedTo;

  final _dbHelper = DBHelper();
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      final task = widget.task!;
      _titleController.text = task.title;
      _descController.text = task.description ?? '';
      _dueDate = task.dueDate;
      _priority = task.priority;
      _status = task.status;
      _assignedTo = task.assignedTo;
    }
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _dbHelper.getAllUsers();
    setState(() {
      _users = users;
    });
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final task = Task(
      id: widget.task?.id ?? Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      dueDate: _dueDate,
      priority: _priority,
      status: _status,
      category: '',
      createdBy: widget.currentUser.id,
      assignedTo: widget.currentUser.isAdmin ? _assignedTo : widget.currentUser.id,
    );

    if (widget.task == null) {
      await _dbHelper.insertTask(task);
    } else {
      await _dbHelper.updateTask(task);
    }

    Navigator.pop(context, true);
  }

  void _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Xoá công việc?"),
        content: Text("Bạn có chắc chắn muốn xoá công việc này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Huỷ")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Xoá")),
        ],
      ),
    );

    if (confirm == true && widget.task != null) {
      await _dbHelper.deleteTask(widget.task!.id);
      Navigator.pop(context, true);
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Sửa công việc" : "Thêm công việc"),
        actions: [
          if (isEditing)
            IconButton(onPressed: _deleteTask, icon: Icon(Icons.delete)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Tiêu đề"),
                validator: (val) => val!.isEmpty ? "Vui lòng nhập tiêu đề" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: "Mô tả"),
                maxLines: 3,
              ),
              SizedBox(height: 12),
              ListTile(
                title: Text(_dueDate != null
                    ? "Hạn: ${DateFormat('dd/MM/yyyy').format(_dueDate!)}"
                    : "Chọn ngày đến hạn"),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _priority,
                items: [1, 2, 3]
                    .map((level) =>
                    DropdownMenuItem(value: level, child: Text("Ưu tiên $level")))
                    .toList(),
                onChanged: (val) => setState(() => _priority = val!),
                decoration: InputDecoration(labelText: "Mức ưu tiên"),
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Chưa hoàn thành', 'Đang xử lý', 'Đã hoàn thành']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _status = val!),
                decoration: InputDecoration(labelText: "Trạng thái"),
              ),
              SizedBox(height: 12),
              if (widget.currentUser.isAdmin)
                DropdownButtonFormField<String>(
                  value: _assignedTo,
                  items: _users.map((u) {
                    return DropdownMenuItem(value: u.id, child: Text(u.username));
                  }).toList(),
                  onChanged: (val) => setState(() => _assignedTo = val),
                  decoration: InputDecoration(labelText: "Giao cho"),
                  validator: (val) => val == null ? "Chọn người nhận" : null,
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(isEditing ? "Cập nhật" : "Tạo mới"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}