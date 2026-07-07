import 'package:flutter/material.dart';
import '../models/mood_type.dart';

class MoodEmojiPicker extends StatelessWidget {
  final String selectedKey;
  final ValueChanged<String> onSelected;

  const MoodEmojiPicker({
    super.key,
    required this.selectedKey,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: MoodType.all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final mood = MoodType.all[index];
          final selected = mood.key == selectedKey;
          return GestureDetector(
            onTap: () => onSelected(mood.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(18),
                border: selected
                    ? Border.all(color: scheme.primary, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(mood.emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(height: 4),
                  Text(
                    mood.labelTh,
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
