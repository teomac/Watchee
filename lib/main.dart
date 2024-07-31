import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:dima_project/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//for theming
import 'package:provider/provider.dart';
import 'package:dima_project/theme/theme_provider.dart';

enum ThemeOptions { light, dark, system }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //set the app to only portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  //this for applying theme
  late ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    _themeProvider = ThemeProvider();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _themeProvider.loadThemeMode();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _themeProvider,
        child:
            Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
            ), // Customize your light theme here
            darkTheme:
                ThemeData(useMaterial3: true, brightness: Brightness.dark),
            // Customize your dark theme here
            themeMode: themeProvider.themeMode,
            home: WidgetTree(),
          );
        }));
  }
}
