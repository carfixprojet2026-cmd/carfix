import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_colors.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/oils_catalog/presentation/screens/oils_catalog_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully for carfix-33875.');
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  // Set system UI overlay style to dark luxury theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surfaceContainerLowest,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const CarFixApp());
}

class CarFixApp extends StatelessWidget {
  const CarFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CARfix - Precision Auto Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryOrange,
          secondary: AppColors.orangeGlow,
          surface: AppColors.surfaceContainer,
        ),
      ),
      home: Builder(
        builder: (context) {
          return SplashScreen(
            onInitialized: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const OilsCatalogScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
