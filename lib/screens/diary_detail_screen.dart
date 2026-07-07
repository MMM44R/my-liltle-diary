import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../models/mood_type.dart';
import '../services/database_service.dart';
import 'diary_editor_screen.dart';

class DiaryDetailScreen extends StatefulWidget {
  final DiaryEntry entry;
  const DiaryDetailScreen({super.key, required this.entry});

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  late DiaryEntry _entry;
  final DatabaseService _db = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  Future<void> _edit() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => DiaryEditorScreen(existing: _entry)),
    );
    if (changed == true) {
      final refreshed = await _db.getEntryById(_entry.id!);
      if (refreshed != null) setState(() => _entry = refreshed);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ลบบันทึกนี้?'),
        content: const Text('ลบแล้วจะไม่สามารถกู้คืนได้นะ 🥺'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ยกเลิก')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ลบ', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _db.deleteEntry(_entry.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mood = MoodType.byKey(_entry.mood);
    final dateStr =
        DateFormat('EEEE d MMMM yyyy • HH:mm', 'th').format(_entry.date);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: _edit, icon: const Icon(Icons.edit_outlined)),
          IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline, color: Colors.red)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(mood.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _entry.title.isEmpty ? '(ไม่มีหัวข้อ)' : _entry.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(dateStr,
                style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
            const SizedBox(height: 16),
            if (_entry.imagePaths.isNotEmpty)
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _entry.imagePaths.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(
                      File(_entry.imagePaths[i]),
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            if (_entry.imagePaths.isNotEmpty) const SizedBox(height: 20),
            Text(
              _entry.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
