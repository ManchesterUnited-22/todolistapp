import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_app/ai/tour_engine.dart';
import 'package:smart_app/ai/tour_scripts.dart';
import 'package:smart_app/ai/ai_client.dart';

class AppController extends ChangeNotifier {
  AppController._internal();
  static final AppController instance = AppController._internal();

  static const String _prefKey = 'is_first_time_user';

  SharedPreferences? _prefs;
  bool _isTourActive = false;
  OverlayEntry? _skipOverlay;
  PageController? _pageController;

  bool get isTourActive => _isTourActive;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final isFirst = _prefs?.getBool(_prefKey) ?? true;
    if (isFirst) {
      _isTourActive = true;
    } else {
      _isTourActive = false;
    }
    notifyListeners();
  }

  Future<void> startTour(BuildContext context) async {
    _isTourActive = true;
    notifyListeners();
    _showSkipOverlay(context);
    // Try fetching dynamic script from AI with 5s timeout, fallback to offline
    List<Map<String, dynamic>>? script;
    try {
      debugPrint('AppController: fetching tour script from AI...');
      script = await fetchTourScriptFromAI(timeout: const Duration(seconds: 5));
      if (script == null) {
        debugPrint(
          'AppController: AI did not return a valid script, using offline fallback',
        );
      } else {
        debugPrint(
          'AppController: AI script loaded (${script.length} commands)',
        );
      }
    } catch (_) {
      debugPrint(
        'AppController: error while fetching AI script, using fallback',
      );
      script = null;
    }

    final toRun = script ?? offlineTourScript;
    try {
      await TourEngine.instance.runScript(context, toRun);
    } catch (_) {}
  }

  Future<void> stopTour() async {
    _isTourActive = false;
    notifyListeners();
    _removeSkipOverlay();
    try {
      TourEngine.instance.stop();
    } catch (_) {}
    try {
      await _prefs?.setBool(_prefKey, false);
    } catch (_) {}
  }

  void _showSkipOverlay(BuildContext context) {
    _removeSkipOverlay();
    final overlay = Overlay.of(context);

    _skipOverlay = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          top: 40,
          right: 16,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  await stopTour();
                },
                child: const Text(
                  'Bỏ qua',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_skipOverlay!);
  }

  void _removeSkipOverlay() {
    try {
      _skipOverlay?.remove();
    } catch (_) {}
    _skipOverlay = null;
  }

  /// Allow screens to register their PageController so the tour can animate pages.
  void registerPageController(PageController controller) {
    _pageController = controller;
  }

  PageController? get pageController => _pageController;
}
