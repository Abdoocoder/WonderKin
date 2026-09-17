import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'core/storage/database.dart';
import 'core/audio/audio_manager.dart';
import 'core/theme/app_theme.dart';
import 'features/parental_gate/parental_gate.dart';

// Import screens
import 'features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Easy Localization
  await EasyLocalization.ensureInitialized();
  
  // Initialize Database
  final database = AppDatabase();
  
  // Initialize Audio Manager
  final audioManager = AudioManager();
  await audioManager.initialize();
  
  // Load saved settings
  final settings = await database.settingsDao.getSettings();
  audioManager.setSfxVolume(settings.soundVolume);
  audioManager.setMusicVolume(settings.musicVolume);
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/i18n',
      fallbackLocale: const Locale('ar'),
      child: MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: database),
          Provider<AudioManager>.value(value: audioManager),
          ChangeNotifierProvider(create: (_) => ParentalGateProvider(database)),
        ],
        child: const KidsAdventureApp(),
      ),
    ),
  );
}

class KidsAdventureApp extends StatelessWidget {
  const KidsAdventureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'عالم المغامرات الذكي',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      home: const AppWrapper(),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startBackgroundMusic();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audioManager = context.read<AudioManager>();
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        audioManager.pauseMusic();
      case AppLifecycleState.resumed:
        audioManager.resumeMusic();
      default:
        break;
    }
  }

  void _startBackgroundMusic() {
    final audioManager = context.read<AudioManager>();
    audioManager.playMusic('background_music');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParentalGateProvider>(
      builder: (context, gateProvider, _) {
        return gateProvider.isScreenTimeExceeded
            ? const ScreenTimeExceededScreen()
            : const HomeScreen();
      },
    );
  }
}

class ScreenTimeExceededScreen extends StatelessWidget {
  const ScreenTimeExceededScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bedtime_rounded,
                  size: 120,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'وقت الراحة! 🌙',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'حان وقت استراحة عينيك وعقلك.\nيمكنك اللعب مرة أخرى غداً!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('العودة للرئيسية'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}