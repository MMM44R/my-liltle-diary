import 'package:shared_preferences/shared_preferences.dart';

/// จัดการรหัส PIN 4 หลัก (ถ้าผู้ใช้เลือกเปิดใช้งาน)
class PinService {
  static const _kPinEnabled = 'pin_enabled';
  static const _kPinCode = 'pin_code';

  Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kPinEnabled) ?? false;
  }

  Future<void> setPinEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPinEnabled, enabled);
    if (!enabled) {
      await prefs.remove(_kPinCode);
    }
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPinCode, pin);
    await prefs.setBool(_kPinEnabled, true);
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kPinCode);
    return saved != null && saved == pin;
  }

  Future<bool> hasPinSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPinCode) != null;
  }
}
