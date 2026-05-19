import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

enum TimerPhase {
  idle,
  preStart,
  focusing,
  breaking,
  overtime,
  paused,
  stopped,
}

class TimerService extends ChangeNotifier {
  TimerService._();
  static final instance = TimerService._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await NotificationService.instance.initialize();
    await _restoreState();
  }

  Timer? _ticker;
  TimerPhase _phase = TimerPhase.idle;
  TimerPhase get phase => _phase;

  int _remainingSeconds = 0;
  int get remainingSeconds => _remainingSeconds;

  int focusDurationMinutes = 0;
  int breakDurationMinutes = 0;

  String? taskDocId;

  int accumulatedFocusSeconds = 0;
  int accumulatedBreakSeconds = 0;

  // overrun tracking
  bool isOverrun = false;
  int overrunSeconds = 0;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _setPhase(TimerPhase p) {
    _phase = p;
    notifyListeners();
  }

  Future<String?> startSession({
    required int focusMinutes,
    required int breakMinutes,
    required String uid,
  }) async {
    await initialize();
    // create a task document to attach session data
    final now = DateTime.now();
    final dateString =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final docRef = await _db.collection('tasks').add({
      'title': 'Phiên tập trung',
      'task_name': 'Phiên tập trung',
      'detail': null,
      'category': null,
      'priority': 'Vừa',
      'way': 'promodoro',
      'stat': 'Đang làm',
      'createdAt': FieldValue.serverTimestamp(),
      'focus_duration': focusMinutes,
      'break_duration': breakMinutes,
      'date_string': dateString,
      'timestamp': FieldValue.serverTimestamp(),
      'uid': uid,
    });

    taskDocId = docRef.id;
    focusDurationMinutes = focusMinutes;
    breakDurationMinutes = breakMinutes;
    accumulatedFocusSeconds = 0;
    accumulatedBreakSeconds = 0;

    // start 5s pre-start countdown
    _startPreStart();
    return taskDocId;
  }

  void _startPreStart() {
    _ticker?.cancel();
    _remainingSeconds = 5;
    _setPhase(TimerPhase.preStart);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      _remainingSeconds -= 1;
      notifyListeners();
      if (_remainingSeconds <= 0) {
        t.cancel();
        _startFocusing();
      }
    });
  }

  void _startFocusing() {
    _ticker?.cancel();
    _remainingSeconds = focusDurationMinutes * 60;
    _setPhase(TimerPhase.focusing);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) async {
      _remainingSeconds -= 1;
      accumulatedFocusSeconds += 1;
      // save periodically
      if (accumulatedFocusSeconds % 5 == 0) await _saveState();
      if (_remainingSeconds <= 0) {
        // Enter overtime behavior: notify user, then keep counting overtime until user stops or moves to break
        t.cancel();
        await _persistAccumulatedTimes();
        _enterOverrun();
      }
      notifyListeners();
    });
  }

  void _startBreaking() {
    _ticker?.cancel();
    _remainingSeconds = breakDurationMinutes * 60;
    _setPhase(TimerPhase.breaking);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      _remainingSeconds -= 1;
      accumulatedBreakSeconds += 1;
      if (_remainingSeconds <= 0) {
        t.cancel();
        _persistAccumulatedTimes();
        // after break, start a new focus session automatically
        _startFocusing();
      }
      notifyListeners();
    });
  }

  void _enterOverrun() {
    isOverrun = true;
    overrunSeconds = 0;
    _setPhase(TimerPhase.overtime);
    // send notification once
    NotificationService.instance.showSimpleNotification(
      title: 'Đã quá thời gian tập trung',
      body:
          'Bạn đã vượt quá thời gian tập trung. Nhấn Stop nếu muốn dừng, hoặc để tiếp tục tính overtime.',
    );

    _ticker = Timer.periodic(const Duration(seconds: 1), (t) async {
      overrunSeconds += 1;
      accumulatedFocusSeconds += 1;
      if (overrunSeconds % 60 == 0) await _saveState();
      notifyListeners();
    });
  }

  /// User chooses to stop overtime and switch to break
  void stopOverrunAndStartBreak() {
    if (!isOverrun) return;
    _ticker?.cancel();
    isOverrun = false;
    overrunSeconds = 0;
    _persistAccumulatedTimes();
    _startBreaking();
  }

  void pauseSession() {
    if (_phase == TimerPhase.idle || _phase == TimerPhase.stopped) return;
    _ticker?.cancel();
    _setPhase(TimerPhase.paused);
    // persist partial times
    _persistAccumulatedTimes();
    _saveState();
  }

  void resumeSession() {
    if (_phase != TimerPhase.paused) return;
    // resume last known phase
    // For simplicity, resume focusing if remaining>0, else resume overtime
    if (_remainingSeconds > 0) {
      _setPhase(TimerPhase.focusing);
      _ticker = Timer.periodic(const Duration(seconds: 1), (t) async {
        _remainingSeconds -= 1;
        accumulatedFocusSeconds += 1;
        if (accumulatedFocusSeconds % 5 == 0) await _saveState();
        if (_remainingSeconds <= 0) {
          t.cancel();
          _persistAccumulatedTimes();
          _enterOverrun();
        }
        notifyListeners();
      });
    } else if (isOverrun) {
      _setPhase(TimerPhase.overtime);
      _ticker = Timer.periodic(const Duration(seconds: 1), (t) async {
        overrunSeconds += 1;
        accumulatedFocusSeconds += 1;
        if (overrunSeconds % 60 == 0) await _saveState();
        notifyListeners();
      });
    }
  }

  void stopSession({bool markCompleted = false}) {
    _ticker?.cancel();
    _setPhase(TimerPhase.stopped);
    _persistAccumulatedTimes(completed: markCompleted);
  }

  Future<void> _persistAccumulatedTimes({bool completed = false}) async {
    if (taskDocId == null) return;
    final data = <String, dynamic>{};
    // convert seconds to minutes (rounded down)
    data['total_focus_time'] = (accumulatedFocusSeconds / 60).floor();
    data['total_break_time'] = (accumulatedBreakSeconds / 60).floor();
    data['timestamp'] = FieldValue.serverTimestamp();
    if (completed) data['completedAt'] = FieldValue.serverTimestamp();
    try {
      await _db
          .collection('tasks')
          .doc(taskDocId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print('Error persisting timer totals: $e');
    }
    await _saveState();
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('timer_taskDocId', taskDocId ?? '');
      await prefs.setString('timer_phase', _phase.toString());
      await prefs.setInt('timer_focusMinutes', focusDurationMinutes);
      await prefs.setInt('timer_breakMinutes', breakDurationMinutes);
      await prefs.setInt('timer_remainingSeconds', _remainingSeconds);
      await prefs.setInt('timer_accFocus', accumulatedFocusSeconds);
      await prefs.setInt('timer_accBreak', accumulatedBreakSeconds);
      await prefs.setBool('timer_isOverrun', isOverrun);
      await prefs.setInt('timer_overrun', overrunSeconds);
      await prefs.setInt(
        'timer_savedAt',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      if (kDebugMode) print('Error saving timer state: $e');
    }
  }

  Future<void> _restoreState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTask = prefs.getString('timer_taskDocId') ?? '';
      if (savedTask.isEmpty) return;
      taskDocId = savedTask;
      final phaseStr = prefs.getString('timer_phase') ?? '';
      focusDurationMinutes = prefs.getInt('timer_focusMinutes') ?? 0;
      breakDurationMinutes = prefs.getInt('timer_breakMinutes') ?? 0;
      final savedRemaining = prefs.getInt('timer_remainingSeconds') ?? 0;
      accumulatedFocusSeconds = prefs.getInt('timer_accFocus') ?? 0;
      accumulatedBreakSeconds = prefs.getInt('timer_accBreak') ?? 0;
      isOverrun = prefs.getBool('timer_isOverrun') ?? false;
      overrunSeconds = prefs.getInt('timer_overrun') ?? 0;
      final savedAt = prefs.getInt('timer_savedAt') ?? 0;
      final elapsed = DateTime.now().millisecondsSinceEpoch - savedAt;
      final elapsedSec = (elapsed / 1000).floor();

      // derive phase
      if (phaseStr.contains('preStart')) {
        var newRem = savedRemaining - elapsedSec;
        if (newRem > 0) {
          _remainingSeconds = newRem;
          _startPreStart();
        } else {
          _startFocusing();
        }
      } else if (phaseStr.contains('focusing')) {
        var newRem = savedRemaining - elapsedSec;
        if (newRem > 0) {
          _remainingSeconds = newRem;
          _startFocusing();
        } else {
          // became overtime
          overrunSeconds = (-newRem);
          isOverrun = true;
          _enterOverrun();
        }
      } else if (phaseStr.contains('breaking')) {
        var newRem = savedRemaining - elapsedSec;
        if (newRem > 0) {
          _remainingSeconds = newRem;
          _startBreaking();
        } else {
          // resume focusing
          _startFocusing();
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error restoring timer state: $e');
    }
  }
}
