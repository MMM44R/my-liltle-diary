import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onDone;
  const WelcomeScreen({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // ภาพประกอบน่ารักแบบ emoji/icon (ไม่ต้องพึ่งไฟล์ภาพภายนอก)
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🐰', style: TextStyle(fontSize: 100)),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                children: const [
                  Text('⭐', style: TextStyle(fontSize: 28)),
                  Text('🎀', style: TextStyle(fontSize: 28)),
                  Text('🌸', style: TextStyle(fontSize: 28)),
                  Text('💖', style: TextStyle(fontSize: 28)),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to\nMy Little Diary 🌸',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'บันทึกทุกความรู้สึกและเรื่องราวน่ารัก ๆ ของคุณ\nไว้ในที่เดียว ปลอดภัย เก็บไว้ในเครื่องของคุณเท่านั้น',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onSurface.withOpacity(0.7)),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDone,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('เริ่มต้นใช้งาน 💕',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
