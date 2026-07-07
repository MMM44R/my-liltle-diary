import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../models/mood_type.dart';

class DiaryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;

  const DiaryCard({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mood = MoodType.byKey(entry.mood);
    final dateStr = DateFormat('d MMM yyyy • HH:mm', 'th').format(entry.date);
    final hasImage = entry.imagePaths.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: Text(mood.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title.isEmpty ? '(ไม่มีหัวข้อ)' : entry.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7)),
                    ),
                    const SizedBox(height: 6),
                    Text(dateStr,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5))),
                  ],
                ),
              ),
              if (hasImage) ...[
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(entry.imagePaths.first),
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: 52,
                      height: 52,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
