import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/diary_entry.dart';
import '../services/database_service.dart';
import '../widgets/mood_emoji_picker.dart';

class DiaryEditorScreen extends StatefulWidget {
  final DiaryEntry? existing;
  final DateTime? initialDate;

  const DiaryEditorScreen({super.key, this.existing, this.initialDate});

  @override
  State<DiaryEditorScreen> createState() => _DiaryEditorScreenState();
}

class _DiaryEditorScreenState extends State<DiaryEditorScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final DatabaseService _db = DatabaseService.instance;
  final ImagePicker _picker = ImagePicker();

  late DateTime _date;
  String _mood = 'happy';
  List<String> _imagePaths = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _contentCtrl.text = e.content;
      _mood = e.mood;
      _date = e.date;
      _imagePaths = List.from(e.imagePaths);
    } else {
      _date = widget.initialDate ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _imagePaths.add(file.path));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(picked.year, picked.month, picked.day, _date.hour,
            _date.minute);
      });
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty && _contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เขียนอะไรสักหน่อยนะ 🥺')),
      );
      return;
    }
    setState(() => _saving = true);

    final entry = DiaryEntry(
      id: widget.existing?.id,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      mood: _mood,
      date: _date,
      imagePaths: _imagePaths,
      createdAt: widget.existing?.createdAt,
    );

    if (widget.existing != null) {
      await _db.updateEntry(entry);
    } else {
      await _db.insertEntry(entry);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'แก้ไขบันทึก 📝' : 'บันทึกใหม่ 🌸'),
        actions: [
          IconButton(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.check_circle),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('วันนี้รู้สึกยังไงบ้าง?',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            MoodEmojiPicker(
              selectedKey: _mood,
              onSelected: (m) => setState(() => _mood = m),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 10),
                    Text(
                        '${_date.day}/${_date.month}/${_date.year}  ${_date.hour.toString().padLeft(2, '0')}:${_date.minute.toString().padLeft(2, '0')}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(hintText: 'หัวข้อ...'),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentCtrl,
              decoration:
                  const InputDecoration(hintText: 'วันนี้เกิดอะไรขึ้นบ้าง...'),
              maxLines: 8,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('แนบรูปภาพ'),
                ),
              ],
            ),
            if (_imagePaths.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imagePaths.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(_imagePaths[i]),
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _imagePaths.removeAt(i)),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'กำลังบันทึก...' : 'บันทึก 💖'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
