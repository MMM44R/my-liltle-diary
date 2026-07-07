import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pin_service.dart';
import '../services/theme_service.dart';
import '../services/backup_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PinService _pinService = PinService();
  final BackupService _backupService = BackupService();
  bool _pinEnabled = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final enabled = await _pinService.isPinEnabled();
    setState(() => _pinEnabled = enabled);
  }

  Future<void> _togglePin(bool value) async {
    if (value) {
      final pin = await _askForNewPin();
      if (pin != null && pin.length == 4) {
        await _pinService.setPin(pin);
        setState(() => _pinEnabled = true);
      }
    } else {
      await _pinService.setPinEnabled(false);
      setState(() => _pinEnabled = false);
    }
  }

  Future<String?> _askForNewPin() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ตั้งรหัส PIN 4 หลัก'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(hintText: '••••'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      await _backupService.exportToJson();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('สำรองข้อมูลสำเร็จ 🌸')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    try {
      final count = await _backupService.importFromJson();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('นำเข้าข้อมูลสำเร็จ $count รายการ 🎀')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();

    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่า ⚙️')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'ความปลอดภัย'),
          SwitchListTile(
            title: const Text('เปิดใช้รหัส PIN 4 หลัก'),
            subtitle: const Text('ล็อกแอปด้วยรหัสก่อนเข้าใช้งาน'),
            value: _pinEnabled,
            onChanged: _togglePin,
          ),
          const Divider(),
          const _SectionHeader(title: 'ธีม'),
          ...AppThemeName.values.map((t) => RadioListTile<AppThemeName>(
                title: Text(t.labelTh),
                value: t,
                groupValue: themeService.themeName,
                activeColor: t.seedColor,
                onChanged: (v) {
                  if (v != null) themeService.setTheme(v);
                },
              )),
          SwitchListTile(
            title: const Text('โหมดกลางคืน (Dark Mode)'),
            value: themeService.isDarkMode,
            onChanged: (v) => themeService.setDarkMode(v),
          ),
          const Divider(),
          const _SectionHeader(title: 'สำรองข้อมูล'),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: const Text('Export ข้อมูลเป็น JSON'),
            subtitle: const Text('บันทึกและแชร์ไฟล์สำรองข้อมูล'),
            enabled: !_busy,
            onTap: _export,
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Import ข้อมูลจาก JSON'),
            subtitle: const Text('กู้คืนข้อมูลจากไฟล์สำรอง'),
            enabled: !_busy,
            onTap: _import,
          ),
          const Divider(),
          const _SectionHeader(title: 'เกี่ยวกับแอป'),
          const ListTile(
            leading: Icon(Icons.favorite, color: Colors.pink),
            title: Text('My Little Diary'),
            subtitle: Text('เวอร์ชัน 1.0.0 • ข้อมูลทั้งหมดเก็บในเครื่องของคุณ'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
