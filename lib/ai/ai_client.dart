import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:smart_app/ai/ai_prompt.dart';
import 'package:smart_app/ai/ai_services.dart';

/// Fetch a tour script from an AI service with retries, robust JSON extraction
/// and schema validation. Returns `null` on failure so callers can use a
/// local fallback script.
Future<List<Map<String, dynamic>>?> fetchTourScriptFromAI({
  required Duration timeout,
  int maxRetries = 2,
}) async {
  final prompt = buildTourSystemPrompt();

  final key = AIService.instance.apiKey;
  if (key.isEmpty) {
    debugPrint('AI client: no API key configured (GOOGLE_API_KEY empty)');
    return null;
  }

  var attempt = 0;
  var backoff = const Duration(milliseconds: 700);

  while (attempt < maxRetries) {
    attempt += 1;
    debugPrint('AI client: fetch attempt #$attempt');

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: key,
        systemInstruction: Content.system(
          'You are a comic-style in-app assistant. Return ONLY a JSON array matching the schema.',
        ),
      );

      final future = model
          .generateContent([Content.text(prompt)])
          .then((resp) => resp.text ?? '');
      final text = await future.timeout(timeout);

      if (text.trim().isEmpty) {
        debugPrint('AI client: received empty response');
      } else {
        final jsonStr = _extractJsonArray(text);
        if (jsonStr == null) {
          debugPrint('AI client: failed to extract JSON array from response');
        } else {
          try {
            final data = jsonDecode(jsonStr);
            if (data is List) {
              final parsed = <Map<String, dynamic>>[];
              for (final item in data) {
                if (item is Map) {
                  parsed.add(Map<String, dynamic>.from(item));
                }
              }
              if (_validateScript(parsed)) {
                debugPrint(
                  'AI client: fetched valid script with ${parsed.length} commands',
                );
                return parsed;
              }
              debugPrint('AI client: script did not pass validation');
            } else {
              debugPrint('AI client: extracted JSON is not a List');
            }
          } catch (e, st) {
            debugPrint('AI client: jsonDecode error: $e\n$st');
          }
        }
      }
    } on TimeoutException catch (e) {
      debugPrint('AI client: timeout on attempt $attempt: $e');
    } catch (e, st) {
      debugPrint('AI client: error on attempt $attempt: $e\n$st');
    }

    if (attempt >= maxRetries) break;
    await Future.delayed(backoff);
    backoff *= 2;
  }

  debugPrint('AI client: all attempts failed, returning null');
  return null;
}

String? _extractJsonArray(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;

  final fenced = RegExp(
    r'```(?:json)?\s*([\s\S]*?)```',
    caseSensitive: false,
  ).firstMatch(trimmed);
  final candidate = fenced?.group(1)?.trim() ?? trimmed;

  final start = candidate.indexOf('[');
  if (start == -1) return null;

  var depth = 0;
  for (var i = start; i < candidate.length; i++) {
    final char = candidate[i];
    if (char == '[') depth++;
    if (char == ']') {
      depth--;
      if (depth == 0) {
        return candidate.substring(start, i + 1);
      }
    }
  }
  return null;
}

bool _validateScript(List<Map<String, dynamic>> script) {
  const allowed = {'speak', 'delay', 'focus_feature', 'navigate'};
  const allowedKeys = {
    'neo_tab_home',
    'neo_tab_stats',
    'neo_tab_calendar',
    'neo_tab_profile',
    'neo_nut_mic',
    'neo_thanh_task',
  };

  for (final cmd in script) {
    final t = cmd['type'];
    if (t is! String || !allowed.contains(t)) return false;
    if (t == 'speak') {
      if (cmd['text'] is! String) return false;
    } else if (t == 'delay') {
      if (cmd['duration'] is! int) return false;
    } else if (t == 'focus_feature') {
      if (cmd['key'] is! String) return false;
      if (cmd['duration'] is! int) return false;
      final key = cmd['key'] as String;
      if (!allowedKeys.contains(key)) return false;
    } else if (t == 'navigate') {
      final idx = cmd['page_index'];
      if (idx is! int) return false;
      if (idx < 0 || idx > 3) return false;
    }
  }
  return true;
}
