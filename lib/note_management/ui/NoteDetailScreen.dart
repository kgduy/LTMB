import 'package:flutter/material.dart';
import '../model/Note.dart';
import 'NoteForm.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  Color _getColorFromHex(String? hex) {
    if (hex == null) return Colors.white;
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  String _priorityText(int p) {
    switch (p) {
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

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(
        2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(
        2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết ghi chú'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NoteForm(note: note)),
              );
              if (updated == true) {
                Navigator.pop(context, true);
              }
            },
          )
        ],
      ),
      backgroundColor: Colors.white, // Nền trắng
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: Theme
                    .of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.black),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.flag, size: 18, color: Colors.grey),
                  SizedBox(width: 5),
                  Text('Mức ưu tiên: ${_priorityText(note.priority)}',
                      style: TextStyle(color: Colors.black)),
                ],
              ),
              SizedBox(height: 8),
              if (note.tags != null && note.tags!.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  children: note.tags!
                      .map((tag) => Chip(label: Text(tag)))
                      .toList(),
                ),
                SizedBox(height: 8),
              ],
              Divider(),
              SelectableText(
                note.content,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              Divider(),
              Text(
                'Tạo lúc: ${_formatDate(note.createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Cập nhật: ${_formatDate(note.modifiedAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}