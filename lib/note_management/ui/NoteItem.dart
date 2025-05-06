import 'package:flutter/material.dart';
import '../model/Note.dart';
import 'NoteForm.dart';
import '../dtb/NoteDatabaseHelper.dart';
import 'NoteDetailScreen.dart';

class NoteItem extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete; // Callback khi xóa thành công
  final VoidCallback onUpdate; // Callback khi ghi chú được cập nhật

  const NoteItem({
    Key? key,
    required this.note,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  int _hexToInt(String hex) {
    hex = hex.replaceAll('#', '');
    return int.parse('FF$hex', radix: 16);
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
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
    final bgColor = note.color != null
        ? Color(_hexToInt(note.color!))
        : Colors.white;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 250, // Giới hạn chiều cao (tuỳ chỉnh theo thiết kế)
      ),
      child: Card(
        color: bgColor.withOpacity(0.2),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded( // Quan trọng để nội dung cuộn được
                child: GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) =>
                          NoteDetailScreen(note: note)),
                    );
                    if (result == true) onUpdate();
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _getPriorityColor(note.priority),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          note.content.length > 100
                              ? '${note.content.substring(0, 100)}...'
                              : note.content,
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: -8,
                          children: (note.tags ?? [])
                              .map((tag) => Chip(label: Text(
                              tag, style: TextStyle(fontSize: 12))))
                              .toList(),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Cập nhật: ${_formatDate(note.modifiedAt)}',
                          style: TextStyle(fontSize: 12,
                              color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 20),
                    onPressed: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NoteForm(note: note)),
                      );
                      if (updated == true) onUpdate();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) =>
                            AlertDialog(
                              title: Text('Xoá ghi chú?'),
                              content: Text(
                                  'Bạn có chắc muốn xoá ghi chú này?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text('Huỷ'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text('Xoá'),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        await NoteDatabaseHelper().deleteNote(note.id!);
                        onDelete();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}