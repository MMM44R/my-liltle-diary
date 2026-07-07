import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/diary_entry.dart';
import '../services/database_service.dart';
import '../widgets/diary_card.dart';
import 'diary_detail_screen.dart';
import 'diary_editor_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DatabaseService _db = DatabaseService.instance;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Set<DateTime> _markedDays = {};
  List<DiaryEntry> _dayEntries = [];

  @override
  void initState() {
    super.initState();
    _loadMonth(_focusedDay);
    _loadDay(_selectedDay);
  }

  Future<void> _loadMonth(DateTime month) async {
    final days = await _db.getEntryDaysInMonth(month);
    if (mounted) setState(() => _markedDays = days);
  }

  Future<void> _loadDay(DateTime day) async {
    final entries = await _db.getEntriesByDate(day);
    if (mounted) setState(() => _dayEntries = entries);
  }

  bool _isMarked(DateTime day) {
    return _markedDays
        .any((d) => d.year == day.year && d.month == day.month && d.day == day.day);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('ปฏิทินบันทึก 🗓️')),
      body: Column(
        children: [
          TableCalendar(
            locale: 'th_TH',
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
              _loadDay(selected);
            },
            onPageChanged: (focused) {
              _focusedDay = focused;
              _loadMonth(focused);
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (_isMarked(day)) {
                  return Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _dayEntries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🌷', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 8),
                        const Text('ยังไม่มีบันทึกในวันนี้'),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DiaryEditorScreen(
                                    initialDate: _selectedDay),
                              ),
                            );
                            _loadDay(_selectedDay);
                            _loadMonth(_focusedDay);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('เขียนบันทึกวันนี้'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: _dayEntries.length,
                    itemBuilder: (context, i) {
                      final entry = _dayEntries[i];
                      return DiaryCard(
                        entry: entry,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    DiaryDetailScreen(entry: entry)),
                          );
                          _loadDay(_selectedDay);
                          _loadMonth(_focusedDay);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
