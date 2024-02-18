import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/utils/ThemeNotifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Authentication/SignupPage.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Chargement du thème depuis SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String themeKey = prefs.getString('theme') ?? 'light';
  ThemeData initialTheme = themeKey == 'light' ? ThemeData.light() : ThemeData.dark();

  // Passer initialTheme à MyApp
  runApp(MyApp(initialTheme: initialTheme));
}

class MyApp extends StatelessWidget {
  final ThemeData initialTheme;

  const MyApp({super.key, required this.initialTheme});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(initialTheme), // Utiliser initialTheme ici
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, _) => MaterialApp(
          title: 'Share',
          debugShowCheckedModeBanner: false,
          theme: theme.getTheme(),
          home: SignUpPage(), // Assurez-vous que SignUpPage est correctement défini
        ),
      ),
    );
  }
}
