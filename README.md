# 🌸 My Little Diary

แอปไดอารี่สีชมพูพาสเทลสไตล์คาวาอี้ เขียนด้วย **Flutter** เก็บข้อมูลทั้งหมดในเครื่อง (SQLite + SharedPreferences) ไม่มีระบบ Login และใช้งานแบบ Offline ได้ 100%

## ✨ ฟีเจอร์
- เขียน/แก้ไข/ลบ ไดอารี่ พร้อมหัวข้อ เนื้อหา วันเวลาอัตโนมัติ
- Mood Tracker ด้วยอีโมจิ 7 แบบ พร้อมสถิติย้อนหลัง (Pie chart)
- แนบรูปภาพจากแกลเลอรี
- ปฏิทินแสดงจุดสีชมพูในวันที่มีบันทึก
- ค้นหาจากหัวข้อ/เนื้อหา/วันที่
- หน้าสถิติ: จำนวนวันที่เขียน, จำนวนบันทึกทั้งหมด, อารมณ์ที่พบบ่อยที่สุด
- ล็อกแอปด้วย PIN 4 หลัก (เปิด/ปิดได้)
- 4 ธีมสี: Pink Dream, Strawberry Milk, Sakura Blossom, Cotton Candy
- รองรับ Dark Mode / Light Mode
- Export / Import ข้อมูลเป็นไฟล์ JSON
- รองรับภาษาไทยเต็มรูปแบบ

## 📁 โครงสร้างโปรเจกต์ (Clean Architecture)
```
lib/
  models/       -> DiaryEntry, MoodType
  services/     -> DatabaseService (SQLite), PinService, ThemeService, BackupService
  screens/      -> ทุกหน้าจอของแอป
  widgets/      -> Widget ที่ใช้ซ้ำ (DiaryCard, MoodEmojiPicker)
  main.dart     -> จุดเริ่มต้นแอปและ routing (Welcome -> PIN -> Home)
```

## ⚠️ หมายเหตุสำคัญเกี่ยวกับไฟล์ที่ให้มา
โค้ดชุดนี้คือ **ซอร์สโค้ด Dart/Flutter ที่สมบูรณ์และพร้อมใช้งาน** (`lib/`, `pubspec.yaml`, `assets/`)
แต่ **ยังไม่มีโฟลเดอร์ `android/` และไม่มีไฟล์ APK ที่ build สำเร็จมาให้** เนื่องจากเครื่องมือที่ใช้สร้างไฟล์นี้ไม่มี Flutter SDK / Android SDK และไม่มีการเชื่อมต่ออินเทอร์เน็ตสำหรับดาวน์โหลด dependency จึงไม่สามารถรันคำสั่ง build จริงให้ได้ในขั้นตอนนี้

ขั้นตอนด้านล่างจะช่วยให้คุณ build เป็น APK และติดตั้งลงเครื่อง Android ได้จริงบนคอมพิวเตอร์ของคุณเอง (ใช้เวลาไม่กี่นาที)

## 🛠️ วิธี Build เป็น APK

### 1. ติดตั้ง Flutter SDK
ดาวน์โหลดและติดตั้งจาก https://docs.flutter.dev/get-started/install แล้วตรวจสอบด้วย
```bash
flutter doctor
```
ต้องมี Android toolchain (Android SDK + Java) พร้อมใช้งาน

### 2. สร้างโฟลเดอร์แพลตฟอร์ม Android
คัดลอกโฟลเดอร์ `my_little_diary` (ที่มี `lib/`, `pubspec.yaml`, `assets/` ให้แล้ว) ไปยังเครื่องที่มี Flutter จากนั้นรัน:
```bash
cd my_little_diary
flutter create . --platforms=android --org com.mylittlediary
```
คำสั่งนี้จะสร้างโฟลเดอร์ `android/` (Gradle, AndroidManifest, MainActivity ฯลฯ) ให้อัตโนมัติ โดย**ไม่ทับ** `lib/` และ `pubspec.yaml` ที่มีอยู่แล้ว

### 3. ติดตั้ง Dependencies
```bash
flutter pub get
```

### 4. Build APK
```bash
flutter build apk --release
```
ไฟล์ APK จะอยู่ที่:
```
build/app/outputs/flutter-apk/app-release.apk
```

### 5. ติดตั้งลงเครื่อง Android
- เชื่อมต่อโทรศัพท์ผ่าน USB แล้วเปิด USB Debugging จากนั้นรัน `flutter install`
- หรือคัดลอกไฟล์ `app-release.apk` ไปยังโทรศัพท์แล้วแตะเพื่อติดตั้ง (ต้องอนุญาต "ติดตั้งจากแหล่งที่ไม่รู้จัก" ในตั้งค่า)

### รันแบบ Debug บนเครื่องจริง/emulator ระหว่างพัฒนา
```bash
flutter run
```

## 🔐 ความเป็นส่วนตัว
ข้อมูลไดอารี่ทั้งหมด (ข้อความ, รูปภาพ, การตั้งค่า, PIN) ถูกเก็บไว้ในเครื่องของผู้ใช้เท่านั้น ผ่าน SQLite และ SharedPreferences ไม่มีการส่งข้อมูลออกไปยังเซิร์ฟเวอร์ใด ๆ

## 📦 Dependencies หลักที่ใช้
`sqflite`, `path_provider`, `shared_preferences`, `image_picker`, `table_calendar`, `fl_chart`, `file_picker`, `share_plus`, `provider`, `google_fonts`, `intl`, `flutter_localizations`
