import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_app/core/app_language.dart';
import 'package:smart_app/core/app_theme.dart';
import 'package:smart_app/core/app_colors.dart';
import 'package:smart_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_app/ai/ai_services.dart';
import 'screens/main_dashboard_screen.dart';
import 'screens/home_tabs.dart';
import 'screens/splash_screen.dart';
import 'screens/charts_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/success_screen.dart';
// AI removed: ai_subagents, ai_config, ai_provider
import 'services/theme_service.dart';
import 'services/task_notification_service.dart';
import 'services/stats_updater.dart';
import 'ai/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final firebaseInit = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await firebaseInit.timeout(const Duration(seconds: 5));
    debugPrint('✓ Firebase initialized');
  } catch (e) {
    debugPrint('⚠ Firebase init error: $e');
  }

  await ThemeService.initialize();
  await TaskNotificationService.instance.initialize();
  await StatsUpdater.instance.initialize();
  AIService.instance.setApiKey(
    const String.fromEnvironment('GOOGLE_API_KEY', defaultValue: ''),
  );
  await AppController.instance.init();
  runApp(const MyApp());
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
                return AnimatedBuilder(
                  animation: AppController.instance,
                  builder: (ctx, _) {
                    final blocking = AppController.instance.isTourActive;
                    return Stack(
                      children: [
                        child ?? const SizedBox.shrink(),
                        if (blocking)
                          const ModalBarrier(
                            dismissible: false,
                            color: Colors.transparent,
                          ),
                      ],
                    );
                  },
                );
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
