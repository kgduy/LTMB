import 'package:flutter/material.dart';
import '../dtb/databasehelper.dart';
import 'TaskItem.dart';
import 'Taskdetail.dart';
import 'Taskform.dart';
import '../models/users.dart';
import '../models/tasks.dart';
import 'Login.dart';

class HomeScreen extends StatefulWidget {
  final User currentUser;

  const HomeScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Task> _tasks = [];
  String _searchQuery = '';
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    List<Task> tasks = widget.currentUser.isAdmin
        ? await _dbHelper.getAllTasks()
        : await _dbHelper.getTasksForUser(widget.currentUser.id!, 'user');

    setState(() {
      _tasks = tasks;
    });
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Task> filtered = _tasks.where((task) {
      final matchSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchStatus = _selectedStatus == null || _selectedStatus == 'Tất cả' || task.status == _selectedStatus;
      return matchSearch && matchStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Công việc của bạn'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'Tất cả', child: Text('Tất cả')),
              PopupMenuItem(value: 'Chưa hoàn thành', child: Text('Chưa hoàn thành')),
              PopupMenuItem(value: 'Đang xử lý', child: Text('Đang xử lý')),
              PopupMenuItem(value: 'Đã hoàn thành', child: Text('Đã hoàn thành')),
            ],
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm công việc...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text('Không có công việc nào'))
                : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, index) {
                return TaskItem(
                  task: filtered[index],
                  onEdit: (task) async {
                    // Mở màn hình chỉnh sửa công việc
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskFormScreen(
                          currentUser: widget.currentUser,
                          task: task,
                        ),
                      ),
                    );
                    _loadTasks();  // Sau khi chỉnh sửa, tải lại danh sách công việc
                  },
                  onDelete: (task) async {
                    // Xử lý xoá công việc trực tiếp trong TaskItem
                    await _dbHelper.deleteTask(task.id!);  // Xoá công việc khỏi cơ sở dữ liệu
                    _loadTasks();  // Sau khi xoá, tải lại danh sách công việc
                  },
                  onTap: (task) async {
                    // Mở màn hình chi tiết công việc khi người dùng bấm vào
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskDetailScreen(task: task),
                      ),
                    );
                    _loadTasks();  // Tải lại danh sách công việc sau khi xem chi tiết
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // Mở màn hình thêm công việc mới
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskFormScreen(currentUser: widget.currentUser),
            ),
          );
          _loadTasks();  // Sau khi thêm công việc mới, tải lại danh sách công việc
        },
      ),
    );
  }
}