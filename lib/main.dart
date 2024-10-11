import 'package:dima_project/pages/account/notifications_page.dart';
import 'package:dima_project/pages/no_internet_page.dart';
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
import 'package:connectivity_plus/connectivity_plus.dart';

enum ThemeOptions { light, dark, system }

Future<void> main() async {
  await initializeApp();
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    runApp(const NoInternetApp());
    return;
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission();

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    String? token = await messaging.getToken();
    if (token != null) {
      await FCMService.storeFCMToken(token);
      await FCMService.storeFCMTokenToFirestore(token);
    }
  }

  FCMService.setupTokenRefreshListener();

  final appLinks = AppLinks();
  final initialUri = await appLinks.getInitialLink();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider()..loadThemeMode(),
      child: MyApp(initialUri: initialUri),
    ),
  );

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
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
    _handleInitialUri();

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _showNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: navigatorKey.currentState!.overlay!.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text(
              'Please check your internet connection and try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
    _connectivitySubscription.cancel();
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
                navigationBarTheme: NavigationBarThemeData(
                    labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold);
                  }
                  return const TextStyle(fontSize: 14);
                })),
              ),
              darkTheme: ThemeData(
                colorScheme: darkColorScheme,
                useMaterial3: true,
                scaffoldBackgroundColor: darkColorScheme.surface,
                navigationBarTheme: NavigationBarThemeData(
                    labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold);
                  }
                  return const TextStyle(fontSize: 14);
                })),
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
