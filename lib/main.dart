import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_links/app_links.dart';

import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/reset_password_screen.dart';
import 'services/notification_service.dart';

/// SUPABASE CONFIG
const String supabaseUrl =
    'https://siujmsbmvwxxbdhlihgd.supabase.co';

const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpdWptc2Jtdnd4eGJkaGxpaGdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1NDQ2MDksImV4cCI6MjA4OTEyMDYwOX0.WlRm9ySc6huXd7018ESMTtkKS4XLmgBszNO0yvoG2DY';

/// THEME
final themeProvider =
    StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// NAVIGATOR
final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    /// FIREBASE INIT
    await Firebase.initializeApp();
    debugPrint("Firebase initialized");

    /// SUPABASE INIT
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    debugPrint("Supabase initialized");
  } catch (e) {
    debugPrint("Initialization error: $e");
  }

  /// STATUS BAR STYLE
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  /// LOCK PORTRAIT
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: FlowMindApp(),
    ),
  );
}

class FlowMindApp extends StatefulWidget {
  const FlowMindApp({super.key});

  @override
  State<FlowMindApp> createState() =>
      _FlowMindAppState();
}

class _FlowMindAppState extends State<FlowMindApp> {
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();

    _initDeepLinks();
    NotificationService.initialize();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    try {
      final Uri? initialUri =
          await _appLinks.getInitialAppLink();

      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint("Deep link error: $e");
    }

    /// LISTEN FOR LINKS
    _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint("Stream error: $err");
      },
    );

    /// SUPABASE PASSWORD RECOVERY
    Supabase.instance.client.auth
        .onAuthStateChange
        .listen((data) {
      if (data.event ==
          AuthChangeEvent.passwordRecovery) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) =>
                const ResetPasswordScreen(),
          ),
        );
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'flowmind' &&
        uri.host == 'reset-password') {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) =>
              const ResetPasswordScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final mode =
            ref.watch(themeProvider);

        return MaterialApp(
          title: 'FlowMind AI',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          themeMode: mode,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const SplashScreen(),
        );
      },
    );
  }
}