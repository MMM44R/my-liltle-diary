import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../services/database_service.dart';
import '../widgets/diary_card.dart';
import 'diary_editor_screen.dart';
import 'diary_detail_screen.dart';
import 'calendar_screen.dart';
import 'search_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  final _pages = const [
    _DiaryListTab(),
    CalendarScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: _pages),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DiaryEditorScreen()),
                );
                setState(() {}); // รีเฟรชรายการหลังเพิ่มบันทึกใหม่
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined), label: 'ไดอารี่'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined), label: 'ปฏิทิน'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined), label: 'สถิติ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: 'ตั้งค่า'),
        ],
      ),
    );
  }
}

class _DiaryListTab extends StatefulWidget {
  const _DiaryListTab();

  @override
  State<_DiaryListTab> createState() => _DiaryListTabState();
}

class _DiaryListTabState extends State<_DiaryListTab> {
  final DatabaseService _db = DatabaseService.instance;
  List<DiaryEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _db.getAllEntries();
    if (mounted) {
      setState(() {
        _entries = entries;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Little Diary 🌸'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _entries.isEmpty
                ? _buildEmpty(context)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90, top: 8),
                    itemCount: _entries.length,
                    itemBuilder: (context, i) {
                      final entry = _entries[i];
                      return DiaryCard(
                        entry: entry,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    DiaryDetailScreen(entry: entry)),
                          );
                          _load();
                        },
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📔', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 12),
                Text('ยังไม่มีบันทึกเลย',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text('แตะปุ่ม + เพื่อเริ่มเขียนไดอารี่ฉบับแรกของคุณ 💕',
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
