import 'package:flutter/material.dart';
import 'screens/customer/splash_screen.dart';

//App-Wide Color Constants 
const Color kPrimaryDarkColor   = Color(0xFF1B2C3B); // Dark Navy (primary bg)
const Color kAccentColor        = Color(0xFFE87E22); // Orange/Gold (buttons)
const Color kSearchBarColor     = Color(0xFFD8D8D9); // Light Grey (search bar)
const Color kCardBgColor        = Color(0xFF253545); // Card background
const Color kTextPrimaryColor   = Colors.white;
const Color kTextSecondaryColor = Color(0xFFAAAAAA);

//Material Color Swatch Builder
MaterialColor createMaterialColor(Color color) {
  List<double> strengths = [.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;
  for (double strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

void main() {
  runApp(const AuraFitARApp());
}

/// Configures the theme and sets [SplashScreen] as the initial route.
class AuraFitARApp extends StatelessWidget {
  const AuraFitARApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuraFit AR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: createMaterialColor(kPrimaryDarkColor),
        scaffoldBackgroundColor: kPrimaryDarkColor,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: kTextPrimaryColor),
          bodyLarge:  TextStyle(color: kTextPrimaryColor),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccentColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
