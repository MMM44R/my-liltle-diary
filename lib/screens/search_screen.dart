import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../services/database_service.dart';
import '../widgets/diary_card.dart';
import 'diary_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final DatabaseService _db = DatabaseService.instance;
  List<DiaryEntry> _results = [];
  bool _searched = false;

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }
    final results = await _db.searchEntries(q.trim());
    setState(() {
      _results = results;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'ค้นหาหัวข้อ เนื้อหา หรือวันที่...',
            border: InputBorder.none,
          ),
          onChanged: _search,
        ),
      ),
      body: !_searched
          ? const Center(child: Text('พิมพ์เพื่อค้นหาบันทึกของคุณ 🔍'))
          : _results.isEmpty
              ? const Center(child: Text('ไม่พบบันทึกที่ค้นหา 🥲'))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: _results.length,
                  itemBuilder: (context, i) {
                    final entry = _results[i];
                    return DiaryCard(
                      entry: entry,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => DiaryDetailScreen(entry: entry)),
                        );
                        _search(_ctrl.text);
                      },
                    );
                  },
                ),
    );
  }
}
