import 'package:dima_project/services/fcm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:dima_project/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/theme/theme_provider.dart';
import 'package:app_links/app_links.dart';
import 'package:dima_project/pages/watchlists/manage_watchlist_page.dart ';
import 'dart:async';
import 'package:logger/logger.dart';

enum ThemeOptions { light, dark, system }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set the app to only portrait mode
  /*await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);*/

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission();

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    // Retrieve FCM Token
    String? token = await messaging.getToken();
    if (token != null) {
      await FMCService.storeFCMToken(token);
      await FMCService.storeFCMTokenToFirestore(token);
    }
  }

  FMCService.setupTokenRefreshListener();

  final appLinks = AppLinks();
  final initialUri = await appLinks.getInitialLink();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider()..loadThemeMode(),
      child: MyApp(initialUri: initialUri),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  final Uri? initialUri;
  const MyApp({super.key, this.initialUri});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _linkSubscription;
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
    _handleInitialUri();
  }

  void _handleIncomingLinks() {
    if (!mounted) return;
    _linkSubscription = AppLinks().uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      _handleLink(uri);
    }, onError: (Object err) {
      if (!mounted) return;
      logger.d('Error occurred: $err');
    });
  }

  Future<void> _handleInitialUri() async {
    if (!mounted) return;
    _handleLink(widget.initialUri);
  }

  void _handleLink(Uri? uri) {
    if (uri == null) return;

    // Extract parameters from the URI
    final watchlistId = uri.queryParameters['watchlistId'];
    final userId = uri.queryParameters['userId'];
    final invitedBy = uri.queryParameters['invitedBy'];

    if (watchlistId != null && userId != null && invitedBy != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => ManageWatchlistPage(
            watchlistId: watchlistId,
            userId: userId,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          theme: ThemeData.light(useMaterial3: true).copyWith(
            // Customize your light theme here
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
            // Customize your dark theme here
            scaffoldBackgroundColor: Colors.black,
            snackBarTheme: const SnackBarThemeData(
                actionTextColor: Colors.red,
                backgroundColor: Colors.black,
                contentTextStyle: TextStyle(color: Colors.white),
                elevation: 20),
          ),
          themeMode: themeProvider.themeMode,
          home: const WidgetTree(),
        );
      },
    );
  }
}
