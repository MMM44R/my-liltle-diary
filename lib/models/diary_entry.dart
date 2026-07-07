import 'dart:convert';

/// โมเดลสำหรับบันทึกไดอารี่หนึ่งรายการ
class DiaryEntry {
  final int? id;
  final String title;
  final String content;
  final String mood; // key ของ MoodType
  final DateTime date; // วันที่ของบันทึก (เลือกโดยผู้ใช้ได้)
  final List<String> imagePaths; // path รูปภาพในเครื่อง
  final DateTime createdAt;
  final DateTime updatedAt;

  DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.date,
    List<String>? imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : imagePaths = imagePaths ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  DiaryEntry copyWith({
    int? id,
    String? title,
    String? content,
    String? mood,
    DateTime? date,
    List<String>? imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      date: date ?? this.date,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'mood': mood,
      'date': date.toIso8601String(),
      'imagePaths': jsonEncode(imagePaths),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    List<String> images = [];
    final rawImages = map['imagePaths'];
    if (rawImages != null && rawImages is String && rawImages.isNotEmpty) {
      try {
        images = List<String>.from(jsonDecode(rawImages));
      } catch (_) {
        images = [];
      }
    }
    return DiaryEntry(
      id: map['id'] as int?,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      mood: map['mood'] ?? 'happy',
      date: DateTime.parse(map['date']),
      imagePaths: images,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  /// คืนค่าสำเนาของบันทึกนี้แบบไม่มี id (ใช้ตอน Import เพื่อสร้างเป็นแถวใหม่เสมอ)
  DiaryEntry asNew() {
    return DiaryEntry(
      title: title,
      content: content,
      mood: mood,
      date: date,
      imagePaths: imagePaths,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// สำหรับ Export/Import เป็น JSON
  Map<String, dynamic> toJson() => toMap();
  factory DiaryEntry.fromJson(Map<String, dynamic> json) =>
      DiaryEntry.fromMap(json);
}
