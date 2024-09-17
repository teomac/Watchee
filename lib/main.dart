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
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider()..loadThemeMode(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
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
