import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/home_page.dart';
import 'screens/sign_in_page.dart';
import 'widget_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme(
            primary: Color(0xFF3A6470),
            onPrimary: Colors.white,
            secondary: Color(0xFF489F32),
            onSecondary: Colors.white,
            error: Colors.red,
            onError: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF253228),
            brightness: Brightness.light,
          ),
          hintColor: Color(0xFF9CB1B7),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF3A6470),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
                side: BorderSide(width: 1.0, color: Color(0xFF75939B)),
                foregroundColor: Color(0xFF3A6470),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
          ),
          textTheme: TextTheme(
              titleLarge: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF253228),
              ),
              titleMedium: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF253228),
              ),
              labelMedium: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF253228),
              ),
              labelSmall: TextStyle(
                fontSize: 12,
                color: Color(0xFF253228),
              ),
              bodyLarge: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF253228),
              ),
              bodyMedium: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF253228),
              )),
          useMaterial3: true,
        ),
        home: const WidgetTree(),
        routes: {
          '/signinpage': (context) => SignInPage(),
          '/homepage': (context) => HomePage(key: homePageKey),
        });
  }
}
