import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood_type.dart';
import '../services/database_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final DatabaseService _db = DatabaseService.instance;
  int _totalEntries = 0;
  int _totalDays = 0;
  Map<String, int> _moodCounts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final total = await _db.getTotalEntries();
    final days = await _db.getTotalDaysWritten();
    final moods = await _db.getMoodCounts();
    setState(() {
      _totalEntries = total;
      _totalDays = days;
      _moodCounts = moods;
      _loading = false;
    });
  }

  MoodType? get _mostFrequentMood {
    if (_moodCounts.isEmpty) return null;
    final topKey =
        _moodCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return MoodType.byKey(topKey);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('สถิติของฉัน 📊')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          emoji: '📅',
                          label: 'วันที่เขียน',
                          value: '$_totalDays วัน',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          emoji: '📝',
                          label: 'บันทึกทั้งหมด',
                          value: '$_totalEntries รายการ',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    emoji: _mostFrequentMood?.emoji ?? '💗',
                    label: 'อารมณ์ที่พบบ่อยที่สุด',
                    value: _mostFrequentMood?.labelTh ?? 'ยังไม่มีข้อมูล',
                    wide: true,
                  ),
                  const SizedBox(height: 20),
                  Text('สัดส่วนอารมณ์ทั้งหมด',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (_moodCounts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('ยังไม่มีข้อมูลอารมณ์')),
                    )
                  else
                    SizedBox(
                      height: 220,
                      child: PieChart(
                        PieChartData(
                          sections: _moodCounts.entries.map((e) {
                            final mood = MoodType.byKey(e.key);
                            return PieChartSectionData(
                              value: e.value.toDouble(),
                              title: '${mood.emoji}\n${e.value}',
                              radius: 70,
                              titleStyle: const TextStyle(fontSize: 12),
                              color: Color((mood.key.hashCode & 0xFFFFFF) |
                                      0xFF000000)
                                  .withOpacity(0.85),
                            );
                          }).toList(),
                          sectionsSpace: 3,
                          centerSpaceRadius: 30,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  ..._moodCounts.entries.map((e) {
                    final mood = MoodType.byKey(e.key);
                    return ListTile(
                      leading:
                          Text(mood.emoji, style: const TextStyle(fontSize: 22)),
                      title: Text(mood.labelTh),
                      trailing: Text('${e.value} ครั้ง',
                          style: TextStyle(color: scheme.primary)),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final bool wide;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6))),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
