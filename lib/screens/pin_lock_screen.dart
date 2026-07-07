import 'package:flutter/material.dart';
import '../services/pin_service.dart';

class PinLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const PinLockScreen({super.key, required this.onUnlocked});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final PinService _pinService = PinService();
  String _entered = '';
  String? _error;

  void _onDigit(String d) {
    if (_entered.length >= 4) return;
    setState(() {
      _entered += d;
      _error = null;
    });
    if (_entered.length == 4) {
      _checkPin();
    }
  }

  Future<void> _checkPin() async {
    final ok = await _pinService.verifyPin(_entered);
    if (ok) {
      widget.onUnlocked();
    } else {
      setState(() {
        _error = 'PIN ไม่ถูกต้อง ลองอีกครั้งนะ 🥺';
        _entered = '';
      });
    }
  }

  void _onBackspace() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text('🔒', style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text('ใส่รหัส PIN',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _entered.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? scheme.primary
                          : scheme.primary.withOpacity(0.2),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(_error!, style: TextStyle(color: scheme.error)),
              const Spacer(),
              _buildKeypad(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: keys.map((k) {
        if (k.isEmpty) return const SizedBox.shrink();
        return Material(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => k == '⌫' ? _onBackspace() : _onDigit(k),
            child: Center(
              child: Text(k, style: const TextStyle(fontSize: 22)),
            ),
          ),
        );
      }).toList(),
    );
  }
}
