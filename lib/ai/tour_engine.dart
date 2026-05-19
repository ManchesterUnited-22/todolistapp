import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_app/ai/tour_keys.dart';
import 'package:smart_app/ai/tour_scripts.dart';
import 'package:smart_app/ai/comic_assistant.dart';
import 'package:smart_app/ai/app_controller.dart';

class TourEngine {
  TourEngine._internal();
  static final TourEngine instance = TourEngine._internal();

  OverlayEntry? _highlightOverlay;
  bool _running = false;

  final StreamController<String> _speechController =
      StreamController<String>.broadcast();
  Stream<String> get speechStream => _speechController.stream;

  Future<void> runScript(
    BuildContext context,
    List<Map<String, dynamic>> script,
  ) async {
    if (_running) return;
    _running = true;
    for (final cmd in script) {
      if (!AppController.instance.isTourActive) break;
      final type = cmd['type'] as String?;
      if (type == null) continue;

      if (type == 'speak') {
        final text = cmd['text'] as String? ?? '';
        _speechController.add(text);
      } else if (type == 'delay') {
        final d = cmd['duration'] as int? ?? 2000;
        await Future.delayed(Duration(milliseconds: d));
      } else if (type == 'focus_feature') {
        final keyName = cmd['key'] as String?;
        final int duration = (cmd['duration'] as int?) ?? 1500;
        if (keyName != null) {
          final gk = _findKeyByName(keyName);
          if (gk != null) {
            _showHighlight(context, gk);
            await Future.delayed(Duration(milliseconds: duration));
            _removeHighlight();
          }
        }
      } else if (type == 'navigate') {
        final idx = cmd['page_index'] as int?;
        if (idx != null) {
          // Prefer animating PageController if available (smooth tab change)
          final pc = AppController.instance.pageController;
          if (pc != null) {
            try {
              await pc.animateToPage(
                idx,
                duration: const Duration(milliseconds: 550),
                curve: Curves.easeInOut,
              );
            } catch (_) {}
          } else {
            final routeMap = {
              0: '/dashboard',
              1: '/stats',
              2: '/calendar',
              3: '/profile',
            };
            final route = routeMap[idx];
            if (route != null) {
              try {
                await Navigator.of(context).pushReplacementNamed(route);
              } catch (_) {}
            }
          }
        }
      }

      // small idle between commands to keep UI stable
      await Future.delayed(const Duration(milliseconds: 120));
    }
    _running = false;
  }

  void stop() {
    _running = false;
    _speechController.add('');
    _removeHighlight();
  }

  GlobalKey? _findKeyByName(String name) {
    switch (name) {
      case 'neo_nut_mic':
        return TourKeys.neoNutMic;
      case 'neo_thanh_task':
        return TourKeys.neoThanhTask;
      case 'neo_tab_home':
        return TourKeys.neoTabHome;
      case 'neo_tab_stats':
        return TourKeys.neoTabStats;
      case 'neo_tab_calendar':
        return TourKeys.neoTabCalendar;
      case 'neo_tab_profile':
        return TourKeys.neoTabProfile;
      default:
        return null;
    }
  }

  void _showHighlight(BuildContext context, GlobalKey key) {
    _removeHighlight();
    final overlay = Overlay.of(context);
    final render = key.currentContext?.findRenderObject() as RenderBox?;
    if (render == null) return;
    final size = render.size;
    final offset = render.localToGlobal(Offset.zero);

    _highlightOverlay = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            Positioned.fill(
              child: ModalBarrier(
                color: Colors.black.withOpacity(0.45),
                dismissible: false,
              ),
            ),
            Positioned(
              left: offset.dx - 8,
              top: offset.dy - 8,
              width: size.width + 16,
              height: size.height + 16,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.95),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(color: Colors.yellowAccent, width: 3),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_highlightOverlay!);
  }

  void _removeHighlight() {
    try {
      _highlightOverlay?.remove();
    } catch (_) {}
    _highlightOverlay = null;
  }
}
