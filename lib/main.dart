import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_tabs.dart';
import 'core/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Personal Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeTabs(),
    );
  }
}