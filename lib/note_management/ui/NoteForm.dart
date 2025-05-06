import 'package:flutter/material.dart';
import '../model/Note.dart';
import '../dtb/NoteDatabaseHelper.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class NoteForm extends StatefulWidget {
  final Note? note; // Nếu null là tạo mới, ngược lại là cập nhật

  const NoteForm({Key? key, this.note}) : super(key: key);

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagController;

  int _priority = 2;
  String? _color;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _priority = note?.priority ?? 2;
    _color = note?.color;
    _tags = note?.tags ?? [];
    _tagController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final newNote = Note(
        id: widget.note?.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        priority: _priority,
        createdAt: widget.note?.createdAt ?? now,
        modifiedAt: now,
        tags: _tags,
        color: _color,
      );

      final db = NoteDatabaseHelper();
      if (widget.note == null) {
        await db.insertNote(newNote);
      } else {
        await db.updateNote(newNote);
      }

      Navigator.pop(context, true); // Quay về và báo thành công
    }
  }

  void _pickColor() async {
    Color picked = _color != null ? Color(_hexToInt(_color!)) : Colors.grey;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chọn màu'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: picked,
              onColorChanged: (color) {
                picked = color;
              },
              enableAlpha: false,
              labelTypes: [],
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Chọn'),
              onPressed: () {
                setState(() {
                  _color = '#${picked.value.toRadixString(16).substring(2).toUpperCase()}';
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _colorCircle(String? hex) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, hex),
      child: CircleAvatar(
        backgroundColor: hex != null ? Color(_hexToInt(hex)) : Colors.grey,
        radius: 20,
        child: hex == null ? Icon(Icons.clear, size: 18) : null,
      ),
    );
  }

  int _hexToInt(String hex) {
    hex = hex.replaceAll('#', '');
    return int.parse('FF$hex', radix: 16);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Cập nhật ghi chú' : 'Thêm ghi chú'),
        backgroundColor: _color != null ? Color(_hexToInt(_color!)) : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Nội dung'),
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập nội dung' : null,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _priority,
                decoration: InputDecoration(labelText: 'Mức độ ưu tiên'),
                items: [
                  DropdownMenuItem(value: 1, child: Text('Thấp')),
                  DropdownMenuItem(value: 2, child: Text('Trung bình')),
                  DropdownMenuItem(value: 3, child: Text('Cao')),
                ],
                onChanged: (value) => setState(() => _priority = value!),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Màu:', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: _pickColor,
                    child: CircleAvatar(
                      backgroundColor: _color != null ? Color(_hexToInt(_color!)) : Colors.grey[300],
                      radius: 16,
                    ),
                  )
                ],
              ),
              SizedBox(height: 20),
              Text('Nhãn:', style: TextStyle(fontSize: 16)),
              Wrap(
                spacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () {
                      setState(() => _tags.remove(tag));
                    },
                  );
                }).toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: InputDecoration(hintText: 'Thêm nhãn'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      final tag = _tagController.text.trim();
                      if (tag.isNotEmpty && !_tags.contains(tag)) {
                        setState(() {
                          _tags.add(tag);
                          _tagController.clear();
                        });
                      }
                    },
                  )
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveNote,
                icon: Icon(Icons.save),
                label: Text(isEditing ? 'Cập nhật' : 'Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
