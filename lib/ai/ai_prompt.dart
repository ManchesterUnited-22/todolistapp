import 'package:smart_app/ai/metadata.dart';

String buildTourSystemPrompt() {
  final buffer = StringBuffer();
  buffer.writeln('You are a comic-style in-app assistant.');
  buffer.writeln(
    'Generate a JSON array of commands describing an interactive tour.',
  );
  buffer.writeln('Allowed command objects are:');
  buffer.writeln('- {"type":"speak","text":"..."}');
  buffer.writeln('- {"type":"delay","duration":milliseconds}');
  buffer.writeln(
    '- {"type":"focus_feature","key":"<feature_key>","duration":milliseconds}',
  );
  buffer.writeln('- {"type":"navigate","page_index":0-3}');
  buffer.writeln('Return only a JSON array. No extra text.');
  buffer.writeln(
    'Use these feature keys exactly when focusing UI: neo_tab_home, neo_tab_stats, neo_tab_calendar, neo_tab_profile, neo_nut_mic, neo_thanh_task.',
  );
  buffer.writeln('\nApp feature descriptions:');
  appFeatureMetadata.forEach((k, v) {
    buffer.writeln('- $k: $v');
  });
  buffer.writeln(
    '\nMake the tour concise and friendly. Keep the exact navigation order Home -> Thống kê -> Lịch -> Hồ sơ. Use delays long enough for reading (>=1200ms for main steps).',
  );
  return buffer.toString();
}
