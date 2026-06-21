library voice_ai_service;

import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'voiceassistant/voice_ai_service_tts.dart';
part 'voiceassistant/voice_ai_service_parsing.dart';
part 'voiceassistant/voice_ai_service_conversation.dart';
part 'voiceassistant/voice_ai_service_recommendation.dart';
part 'voiceassistant/voice_ai_service_intent.dart';

class VoiceTaskDraft {
  final String way;
  final String title;
  final String category;
  final int durationMinutes;
  final String priority;
  final DateTime? dueAt;

  const VoiceTaskDraft({
    required this.way,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.priority,
    this.dueAt,
  });
}

enum VoiceTaskStep {
  chooseWay,
  askTitle,
  askCategory,
  askDuration,
  askPriority,
  askDueAt,
  confirmWay,
  confirm,
  done,
}

class VoiceTaskConversationState {
  final VoiceTaskStep step;
  final String? way;
  final String? title;
  final String? category;
  final int? durationMinutes;
  final String? priority;
  final DateTime? dueAt;

  const VoiceTaskConversationState({
    required this.step,
    this.way,
    this.title,
    this.category,
    this.durationMinutes,
    this.priority,
    this.dueAt,
  });

  factory VoiceTaskConversationState.initial() =>
      const VoiceTaskConversationState(step: VoiceTaskStep.chooseWay);

  VoiceTaskConversationState copyWith({
    VoiceTaskStep? step,
    String? way,
    String? title,
    String? category,
    int? durationMinutes,
    String? priority,
    DateTime? dueAt,
    bool clearDueAt = false,
  }) {
    return VoiceTaskConversationState(
      step: step ?? this.step,
      way: way ?? this.way,
      title: title ?? this.title,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      priority: priority ?? this.priority,
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
    );
  }
}

class VoiceTaskConversationReply {
  final VoiceTaskConversationState state;
  final String prompt;
  final bool isComplete;
  final VoiceTaskDraft? draft;

  const VoiceTaskConversationReply({
    required this.state,
    required this.prompt,
    required this.isComplete,
    this.draft,
  });
}

class AiRecommendation {
  final int suggestedFocusMinutes;
  final int suggestedBreakMinutes;
  final String message;

  AiRecommendation({
    required this.suggestedFocusMinutes,
    required this.suggestedBreakMinutes,
    required this.message,
  });
}

class VoiceAiService {
  // Always get API key from dotenv if available, fallback to compile-time define.
  String _apiKey = const String.fromEnvironment(
    'GOOGLE_API_KEY',
    defaultValue: '',
  );
  final FlutterTts _tts = FlutterTts();
  VoiceAiService._();
  static final instance = VoiceAiService._();

  /// Public getter to expose the configured API key for reuse by other modules.
  String get apiKey => _apiKey;

  /// Set API key at runtime (e.g., from secure storage or CI secrets). Avoid
  /// calling this with hard-coded literals in source control.
  void setApiKey(String key) {
    _apiKey = key.trim();
  }

  Future<void> speakText(String text, {double? speechRate}) =>
      voiceAiSpeakText(this, text, speechRate: speechRate);

  /// Dừng phát giọng nói hiện tại (dùng cho nút loa khi người dùng bấm lần 2
  /// để ngắt giữa lúc đang đọc).
  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  /// Gọi sớm (ví dụ khi mở màn hình có nút mic) để engine TTS native được
  /// khởi tạo/bind trước, tránh độ trễ "cold start" ở lần nói đầu tiên
  /// trong session — nguyên nhân khiến lần nghe đầu tiên dễ bị bỏ lỡ.
  Future<void> warmUpTts() async {
    try {
      await _tts.setLanguage('vi-VN');
    } catch (_) {}
  }

  String voicePromptForStep(VoiceTaskConversationState state) =>
      voiceAiVoicePromptForStep(state);

  VoiceTaskConversationReply advanceVoiceTaskConversation(
    String userText,
    VoiceTaskConversationState state,
  ) => voiceAiAdvanceVoiceTaskConversation(userText, state);

  Future<AiRecommendation> recommendFocusBreak({
    required int focusMinutes,
    required int breakMinutes,
  }) => voiceAiRecommendFocusBreak(
    this,
    focusMinutes: focusMinutes,
    breakMinutes: breakMinutes,
  );

  Future<Map<String, dynamic>?> extractIntentFromText(String userText) =>
      voiceAiExtractIntentFromText(this, userText);

  Future<Map<String, dynamic>?> extractTaskFromText(String userText) =>
      voiceAiExtractTaskFromText(this, userText);

  void handleVoiceInput(String resultText) {
    unawaited(voiceAiHandleVoiceInput(this, resultText));
  }
}