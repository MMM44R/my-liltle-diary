import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'services/theme_service.dart';
import 'services/pin_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/pin_lock_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th_TH');
  await initializeDateFormatting('th');
  runApp(const MyLittleDiaryApp());
}

class MyLittleDiaryApp extends StatefulWidget {
  const MyLittleDiaryApp({super.key});

  @override
  State<MyLittleDiaryApp> createState() => _MyLittleDiaryAppState();
}

class _MyLittleDiaryAppState extends State<MyLittleDiaryApp> {
  final ThemeService _themeService = ThemeService();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _themeService.load().then((_) {
      setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return ChangeNotifierProvider<ThemeService>.value(
      value: _themeService,
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'My Little Diary',
            theme: themeService.buildTheme(dark: false),
            darkTheme: themeService.buildTheme(dark: true),
            themeMode:
                themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: const Locale('th', 'TH'),
            supportedLocales: const [Locale('th', 'TH'), Locale('en', 'US')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AppEntryGate(),
          );
        },
      ),
    );
  }
}

/// ตัดสินใจว่าจะแสดงหน้า Welcome, หน้าใส่ PIN หรือหน้า Home
class AppEntryGate extends StatefulWidget {
  const AppEntryGate({super.key});

  @override
  State<AppEntryGate> createState() => _AppEntryGateState();
}

class _AppEntryGateState extends State<AppEntryGate> {
  final PinService _pinService = PinService();
  bool _loading = true;
  bool _seenWelcome = false;
  bool _pinEnabled = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final seen = await ThemeService.hasSeenWelcome();
    final pinOn = await _pinService.isPinEnabled();
    setState(() {
      _seenWelcome = seen;
      _pinEnabled = pinOn;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_seenWelcome) {
      return WelcomeScreen(
        onDone: () async {
          await ThemeService.setSeenWelcome();
          setState(() => _seenWelcome = true);
        },
      );
    }
    if (_pinEnabled) {
      return PinLockScreen(
        onUnlocked: () => setState(() => _pinEnabled = false),
      );
    }
    return const HomeScreen();
  }
}
