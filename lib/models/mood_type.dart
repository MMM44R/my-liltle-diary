/// โมเดลสำหรับอารมณ์ประจำวัน (Mood Tracker)
class MoodType {
  final String key;
  final String emoji;
  final String labelTh;

  const MoodType({
    required this.key,
    required this.emoji,
    required this.labelTh,
  });

  static const List<MoodType> all = [
    MoodType(key: 'happy', emoji: '😊', labelTh: 'มีความสุข'),
    MoodType(key: 'sad', emoji: '😭', labelTh: 'เศร้า'),
    MoodType(key: 'angry', emoji: '😡', labelTh: 'โกรธ'),
    MoodType(key: 'sleepy', emoji: '😴', labelTh: 'ง่วง'),
    MoodType(key: 'love', emoji: '😍', labelTh: 'อินเลิฟ'),
    MoodType(key: 'excited', emoji: '🤩', labelTh: 'ตื่นเต้น'),
    MoodType(key: 'calm', emoji: '😌', labelTh: 'สงบใจ'),
  ];

  static MoodType byKey(String? key) {
    return all.firstWhere(
      (m) => m.key == key,
      orElse: () => all.first,
    );
  }
}
