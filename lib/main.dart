import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'data/local/hive_service.dart';
import 'providers/favorites_provider.dart';
import 'providers/search_provider.dart';
import 'providers/shows_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/upcoming_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final hiveService = HiveService();
  await hiveService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShowsProvider(hiveService)),
        ChangeNotifierProvider(create: (_) => SearchProvider(hiveService)),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(hiveService)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(hiveService)),
        ChangeNotifierProvider(create: (_) => UpcomingProvider()),
      ],
      child: const SmollanMovieVerseApp(),
    ),
  );
}

class SmollanMovieVerseApp extends StatelessWidget {
  const SmollanMovieVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp(
              title: 'Smollan Movie Verse',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: child,
            );
          },
        );
      },
      child: const SplashScreen(),
    );
  }
}
