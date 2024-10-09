import 'package:dima_project/pages/account/notifications_page.dart';
import 'package:dima_project/services/fcm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:dima_project/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/theme/theme_provider.dart';
import 'package:app_links/app_links.dart';
import 'package:dima_project/pages/watchlists/manage_watchlist_page.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dynamic_color/dynamic_color.dart';

enum ThemeOptions { light, dark, system }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Handle notification clicks
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    if (message.data['screen'] == 'notifications') {
      MyUser? currentUser = await UserService().getCurrentUser();
      if (currentUser != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => NotificationsPage(user: currentUser),
          ),
        );
      }
    }
  });
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
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            final ColorScheme lightColorScheme = lightDynamic ??
                ColorScheme.fromSeed(seedColor: Colors.deepPurple);
            final ColorScheme darkColorScheme = darkDynamic ??
                ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple, brightness: Brightness.dark);

            return MaterialApp(
              navigatorKey: navigatorKey,
              theme: ThemeData(
                colorScheme: lightColorScheme,
                useMaterial3: true,
                scaffoldBackgroundColor: lightColorScheme.surface,
              ),
              darkTheme: ThemeData(
                colorScheme: darkColorScheme,
                useMaterial3: true,
                scaffoldBackgroundColor: darkColorScheme.surface,
                snackBarTheme: SnackBarThemeData(
                  backgroundColor: darkColorScheme.surfaceContainerHighest,
                  contentTextStyle: TextStyle(
                      color: darkColorScheme.onSurfaceVariant, fontSize: 16),
                  actionTextColor: darkColorScheme.primary,
                ),
              ),
              themeMode: themeProvider.themeMode,
              home: const WidgetTree(),
            );
          },
        );
      },
    );
  }
}
