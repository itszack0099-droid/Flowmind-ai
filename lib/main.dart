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

const String supabaseUrl =
    'https://siujmsbmvwxxbdhlihgd.supabase.co';

const String supabaseAnonKey =
    'YOUR_SUPABASE_ANON_KEY_HERE';

final themeProvider =
    StateProvider<ThemeMode>((ref) => ThemeMode.dark);

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

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

  runApp(
    const ProviderScope(
      child: FlowMindApp(),
    ),
  );
}

class FlowMindApp extends StatefulWidget {
  const FlowMindApp({super.key});

  @override
  State<FlowMindApp> createState() => _FlowMindAppState();
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
      // ✅ FIXED METHOD
      final Uri? initialUri =
          await _appLinks.getInitialAppLink();

      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint("Deep link error: $e");
    }

    // Listen for incoming links
    _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint("Stream error: $err");
      },
    );

    // Supabase password recovery
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
        final mode = ref.watch(themeProvider);

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