import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/diary_entry.dart';

/// จัดการฐานข้อมูล SQLite ทั้งหมดของแอป (เก็บข้อมูลในเครื่องเท่านั้น)
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_little_diary.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE diary_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            mood TEXT NOT NULL,
            date TEXT NOT NULL,
            imagePaths TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // ---------- CRUD ----------

  Future<int> insertEntry(DiaryEntry entry) async {
    final db = await database;
    return db.insert('diary_entries', entry.toMap()..remove('id'));
  }

  Future<int> updateEntry(DiaryEntry entry) async {
    final db = await database;
    return db.update(
      'diary_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;
    return db.delete('diary_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<DiaryEntry?> getEntryById(int id) async {
    final db = await database;
    final rows =
        await db.query('diary_entries', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return DiaryEntry.fromMap(rows.first);
  }

  Future<List<DiaryEntry>> getAllEntries() async {
    final db = await database;
    final rows =
        await db.query('diary_entries', orderBy: 'date DESC, id DESC');
    return rows.map((e) => DiaryEntry.fromMap(e)).toList();
  }

  Future<List<DiaryEntry>> getEntriesByDate(DateTime day) async {
    final db = await database;
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final rows = await db.query(
      'diary_entries',
      where: 'date >= ? AND date < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return rows.map((e) => DiaryEntry.fromMap(e)).toList();
  }

  /// คืนค่ารายการ "วัน" ที่มีบันทึกในเดือนนั้น ๆ ใช้แสดงจุดสีชมพูบนปฏิทิน
  Future<Set<DateTime>> getEntryDaysInMonth(DateTime month) async {
    final entries = await getAllEntries();
    return entries
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet();
  }

  Future<List<DiaryEntry>> searchEntries(String query) async {
    final db = await database;
    final q = '%$query%';
    final rows = await db.query(
      'diary_entries',
      where: 'title LIKE ? OR content LIKE ? OR date LIKE ?',
      whereArgs: [q, q, q],
      orderBy: 'date DESC',
    );
    return rows.map((e) => DiaryEntry.fromMap(e)).toList();
  }

  // ---------- สถิติ ----------

  Future<Map<String, int>> getMoodCounts() async {
    final entries = await getAllEntries();
    final Map<String, int> counts = {};
    for (final e in entries) {
      counts[e.mood] = (counts[e.mood] ?? 0) + 1;
    }
    return counts;
  }

  Future<int> getTotalEntries() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM diary_entries');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalDaysWritten() async {
    final entries = await getAllEntries();
    final days =
        entries.map((e) => '${e.date.year}-${e.date.month}-${e.date.day}').toSet();
    return days.length;
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('diary_entries');
  }
}
