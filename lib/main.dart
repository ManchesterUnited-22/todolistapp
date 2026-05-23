import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_app/core/app_language.dart';
import 'package:smart_app/core/app_theme.dart';
import 'package:smart_app/core/app_colors.dart';
import 'package:smart_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_app/ai/voice_ai_service.dart';
import 'screens/main_dashboard_screen.dart';
import 'screens/home_tabs.dart';
import 'screens/splash_screen.dart';
import 'screens/charts_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/success_screen.dart';
// AI removed: ai_subagents, ai_config, ai_provider
import 'services/theme_service.dart';
import 'notifications/task_notification_service.dart';
import 'services/stats_updater.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('==> main: WidgetsFlutterBinding initialized');

  // Load environment variables
  var dotenvLoaded = false;
  try {
    await dotenv.load();
    dotenvLoaded = true;
    debugPrint('==> main: dotenv loaded, GOOGLE_API_KEY = \'${dotenv.env['GOOGLE_API_KEY']}\'');
  } catch (e) {
    debugPrint('==> main: dotenv load error: $e');
  }

  try {
    final firebaseInit = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await firebaseInit.timeout(const Duration(seconds: 5));
    debugPrint('==> main: Firebase initialized');
  } catch (e) {
    debugPrint('==> main: Firebase init error: $e');
  }

  try {
    await ThemeService.initialize();
    debugPrint('==> main: ThemeService initialized');
  } catch (e) {
    debugPrint('==> main: ThemeService init error: $e');
  }
  try {
    await TaskNotificationService.instance.initialize();
    debugPrint('==> main: TaskNotificationService initialized');
  } catch (e) {
    debugPrint('==> main: TaskNotificationService init error: $e');
  }
  try {
    await StatsUpdater.instance.initialize();
    debugPrint('==> main: StatsUpdater initialized');
  } catch (e) {
    debugPrint('==> main: StatsUpdater init error: $e');
  }
  try {
    final apiKey = dotenvLoaded ? (dotenv.env['GOOGLE_API_KEY'] ?? '') : '';
    if (apiKey.isNotEmpty) {
      VoiceAiService.instance.setApiKey(apiKey);
      debugPrint('==> main: VoiceAiService API key set');
    } else {
      debugPrint('==> main: VoiceAiService API key skipped because dotenv was not loaded');
    }
  } catch (e) {
    debugPrint('==> main: VoiceAiService setApiKey error: $e');
  }
  runApp(const MyApp());
  debugPrint('==> main: runApp called');
}

Future<void> _bootstrapApp() async {
  try {
    await AppLanguage.initialize().timeout(
      const Duration(seconds: 1),
      onTimeout: () {
        debugPrint('⚠ Language init timeout');
      },
    );
  } catch (error) {
    debugPrint('⚠ Language init error: $error');
  }
  // AI initialization removed.
  debugPrint('✓ Bootstrap complete');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<void> _bootstrapFuture = _bootstrapApp();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguage.locale,
      builder: (context, locale, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.mode,
          builder: (context, themeMode, _) {
            return MaterialApp(
              title: 'AURORA',
              builder: (context, child) {
                return child ?? const SizedBox.shrink();
              },
              debugShowCheckedModeBanner: false,
              locale: locale,
              supportedLocales: AppLanguage.supportedLocales,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (deviceLocale, supportedLocales) {
                if (deviceLocale == null) return AppLanguage.locale.value;
                for (final supported in supportedLocales) {
                  if (supported.languageCode == deviceLocale.languageCode) {
                    return supported;
                  }
                }
                return AppLanguage.locale.value;
              },
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeMode,
              routes: {
                '/dashboard': (context) => const HomeTabs(),
                '/calendar': (context) => const CalendarScreen(),
                '/charts': (context) => const ChartsScreen(),
                '/stats': (context) => const ChartsScreen(),
                '/profile': (context) => const ProfileScreen(),
              },
              home: FutureBuilder<void>(
                future: _bootstrapFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const _StartupLoadingScreen();
                  }
                  return const SplashScreen();
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0d1515),
      body: Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.brand,
          ),
        ),
      ),
    );
  }
}

class WelcomeToDashboardFlow extends StatefulWidget {
  const WelcomeToDashboardFlow({super.key});

  @override
  State<WelcomeToDashboardFlow> createState() => _WelcomeToDashboardFlowState();
}

class _WelcomeToDashboardFlowState extends State<WelcomeToDashboardFlow> {
  bool _showDashboard = false;

  @override
  void initState() {
    super.initState();
    _goToDashboard();
  }

  void _goToDashboard() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() => _showDashboard = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 700),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: _showDashboard
          ? const MainDashboardScreen(key: ValueKey('dashboard'))
          : const SuccessScreen(key: ValueKey('success')),
    );
  }
}
