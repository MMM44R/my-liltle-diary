import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/diary_entry.dart';
import 'database_service.dart';

/// สำรอง (Export) และกู้คืน (Import) ข้อมูลไดอารี่ทั้งหมดเป็นไฟล์ JSON
class BackupService {
  final DatabaseService _db = DatabaseService.instance;

  /// Export ข้อมูลทั้งหมดเป็นไฟล์ JSON แล้วเปิดหน้าต่างแชร์/บันทึกไฟล์
  Future<String> exportToJson() async {
    final entries = await _db.getAllEntries();
    final jsonList = entries.map((e) => e.toJson()).toList();
    final jsonString = const JsonEncoder.withIndent('  ').convert({
      'app': 'My Little Diary',
      'exportedAt': DateTime.now().toIso8601String(),
      'entries': jsonList,
    });

    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'my_little_diary_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(jsonString);

    await Share.shareXFiles([XFile(file.path)],
        text: 'สำรองข้อมูล My Little Diary 🌸');

    return file.path;
  }

  /// Import ข้อมูลจากไฟล์ JSON ที่ผู้ใช้เลือก คืนค่าจำนวนบันทึกที่นำเข้าสำเร็จ
  Future<int> importFromJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) {
      return 0;
    }

    final file = File(result.files.single.path!);
    final content = await file.readAsString();
    final Map<String, dynamic> data = jsonDecode(content);
    final List<dynamic> entriesJson = data['entries'] ?? [];

    int imported = 0;
    for (final e in entriesJson) {
      final entry = DiaryEntry.fromJson(Map<String, dynamic>.from(e));
      // Import เป็นบันทึกใหม่เสมอ (ไม่ทับ id เดิม) เพื่อความปลอดภัยของข้อมูล
      await _db.insertEntry(entry.asNew());
      imported++;
    }
    return imported;
  }
}
