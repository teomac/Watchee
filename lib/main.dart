import 'package:dima_project/pages/account/notifications_page.dart';
import 'package:dima_project/pages/no_internet_page.dart';
import 'package:dima_project/services/fcm_service.dart';
import 'package:dima_project/services/fcm_settings_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:dima_project/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/theme/theme_provider.dart';
import 'package:app_links/app_links.dart';
import 'package:dima_project/pages/watchlists/manage_watchlist_page.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:dima_project/services/custom_auth.dart';
import 'package:dima_project/services/custom_google_auth.dart';
import 'package:dima_project/services/notifications_service.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:dima_project/services/version_control.dart';
import 'package:dima_project/pages/force_update_screen.dart';

enum ThemeOptions { light, dark, system }

class AppDependencies {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;
  final FirebaseMessaging messaging;
  final CustomAuth customAuth;
  final UserService userService;
  final CustomGoogleAuth customGoogleAuth;
  final AppLinks appLinks;
  final WatchlistService watchlistService;
  final FCMService fcmService;
  final FCMSettingsService fcmSettingsService;

  AppDependencies({
    required this.auth,
    required this.firestore,
    required this.googleSignIn,
    required this.messaging,
    required this.customAuth,
    required this.userService,
    required this.customGoogleAuth,
    required this.appLinks,
    required this.watchlistService,
    required this.fcmService,
    required this.fcmSettingsService,
  });

  factory AppDependencies.production() {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final googleSignIn = GoogleSignIn();
    final userService = UserService(auth: auth, firestore: firestore);
    final messaging = FirebaseMessaging.instance;

    return AppDependencies(
      auth: auth,
      firestore: firestore,
      googleSignIn: googleSignIn,
      messaging: messaging,
      customAuth: CustomAuth(firebaseAuth: auth, googleSignIn: googleSignIn),
      userService: UserService(
        auth: auth,
        firestore: firestore,
      ),
      customGoogleAuth: CustomGoogleAuth(
        auth: auth,
        firestore: firestore,
        googleSignIn: googleSignIn,
        userService: userService,
      ),
      appLinks: AppLinks(),
      watchlistService:
          WatchlistService(firestore: firestore, userService: userService),
      fcmService:
          FCMService(firestore: firestore, auth: auth, messaging: messaging),
      fcmSettingsService: FCMSettingsService(firestore: firestore, auth: auth),
    );
  }
}

Future<void> main() async {
  await initializeApp();
}

Future<void> initializeApp({AppDependencies? dependencies}) async {
  //initialize core
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    runApp(const NoInternetApp());
    return;
  }

  //initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check version
  final versionControl = VersionControl();
  final versionStatus = await versionControl.checkVersion();

  if (versionStatus['requiresUpdate']) {
    runApp(ForceUpdateScreen(
      currentVersion: versionStatus['currentVersion'],
      requiredVersion: versionStatus['minimumVersion'],
      updateMessage: versionStatus['updateMessage'],
    ));
    return;
  }

  final deps = dependencies ?? AppDependencies.production();

  // Add these lines after Firebase initialization
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider
        .debug, // Use AndroidProvider.playIntegrity for production
    appleProvider: AppleProvider.deviceCheck,
  );

  final settings = await deps.messaging.requestPermission();
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    String? token = await deps.messaging.getToken();
    if (token != null) {
      await deps.fcmService.storeFCMToken(token);
      await deps.fcmService.storeFCMTokenToFirestore(token);
    }
  }

  deps.fcmService.setupTokenRefreshListener();

  ///////////////////////////////////////
  final initialUri = await deps.appLinks.getInitialLink();

  runApp(_createApp(deps, initialUri));

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

Widget _createApp(AppDependencies deps, Uri? initialUri) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => ThemeProvider()..loadThemeMode(),
      ),
      Provider<FirebaseAuth>(
        create: (_) => deps.auth,
      ),
      Provider<FirebaseFirestore>(
        create: (_) => deps.firestore,
      ),
      Provider<GoogleSignIn>(
        create: (_) => deps.googleSignIn,
      ),
      Provider<FirebaseMessaging>(
        create: (_) => deps.messaging,
      ),
      Provider<UserService>(
        create: (_) => deps.userService,
      ),
      Provider<CustomAuth>(
        create: (_) => deps.customAuth,
      ),
      Provider<CustomGoogleAuth>(
        create: (_) => deps.customGoogleAuth,
      ),
      Provider<WatchlistService>(
        create: (_) => deps.watchlistService,
      ),
      Provider<FCMService>(
        create: (_) => deps.fcmService,
      ),
      Provider<NotificationsService>(
        create: (_) => NotificationsService(),
      ),
      Provider<FCMSettingsService>(
        create: (_) => deps.fcmSettingsService,
      ),
    ],
    child: MyApp(initialUri: initialUri),
  );
}

///////////////////////////////////////////////////////////////////////////

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  final Uri? initialUri;

  const MyApp({
    super.key,
    this.initialUri,
  });

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

  void _setSystemUIOverlayStyle(BuildContext context, ThemeMode themeMode) {
    final isDarkMode = switch (themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDarkMode ? Brightness.light : Brightness.dark,
    ));
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
                //drop everything and show no internet page
                navigatorKey.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const NoInternetPage(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Ok'),
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
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            return Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                _setSystemUIOverlayStyle(context, themeProvider.themeMode);
                final ColorScheme lightColorScheme = lightDynamic ??
                    ColorScheme.fromSeed(seedColor: Colors.deepPurple);
                final ColorScheme darkColorScheme = darkDynamic ??
                    ColorScheme.fromSeed(
                        seedColor: Colors.deepPurple,
                        brightness: Brightness.dark);

                return MaterialApp(
                  navigatorKey: navigatorKey,
                  theme: ThemeData(
                    colorScheme: lightColorScheme,
                    useMaterial3: true,
                    scaffoldBackgroundColor: lightColorScheme.surface,
                    navigationBarTheme: NavigationBarThemeData(labelTextStyle:
                        WidgetStateProperty.resolveWith((states) {
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
                    navigationBarTheme: NavigationBarThemeData(labelTextStyle:
                        WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold);
                      }
                      return const TextStyle(fontSize: 14);
                    })),
                  ),
                  themeMode: themeProvider.themeMode,
                  home: const OrientationControl(child: WidgetTree()),
                );
              },
            );
          },
        );
      },
    );
  }
}

class OrientationControl extends StatefulWidget {
  final Widget child;

  const OrientationControl({super.key, required this.child});

  @override
  State<OrientationControl> createState() => _OrientationControlState();
}

class _OrientationControlState extends State<OrientationControl> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setOrientation(context);
    });
  }

  void _setOrientation(BuildContext context) {
    if (isTablet(context)) {
      AutoOrientation.fullAutoMode();
    } else {
      AutoOrientation.portraitAutoMode();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    AutoOrientation.fullAutoMode();
    super.dispose();
  }
}

bool isTablet(BuildContext context) {
  final shortestSide = MediaQuery.of(context).size.shortestSide;
  final isTablet = shortestSide > 500;
  return isTablet;
}
