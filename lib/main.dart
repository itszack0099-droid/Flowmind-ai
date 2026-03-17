import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

const String supabaseUrl = 'https://siujmsbmvwxxbdhlihgd.supabase.co';

const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
    '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpdWptc2Jtdnd4eGJkaGxpaGdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1NDQ2MDksImV4cCI6MjA4OTEyMDYwOX0'
    '.WlRm9ySc6huXd7018ESMTtkKS4XLmgBszNO0yvoG2DY';

final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    print('[FlowMind] Initializing Supabase with URL: $supabaseUrl');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  if (kDebugMode) {
    print('[FlowMind] Supabase initialized successfully');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: FlowMindApp()));
}

class FlowMindApp extends ConsumerWidget {
  const FlowMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return MaterialApp(
      title: 'FlowMind AI',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const SplashScreen(),
    );
  }
}
