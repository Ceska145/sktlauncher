import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/datasources/product_local_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/batch_provider.dart';
import 'presentation/providers/history_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive'ı initialize et
  await Hive.initFlutter();
  
  // SharedPreferences'i initialize et
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // ThemeProvider'ı initialize et
  final themeProvider = ThemeProvider();
  await themeProvider.loadPreferences();
  
  runApp(MyApp(
    sharedPreferences: sharedPreferences,
    themeProvider: themeProvider,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  final ThemeProvider themeProvider;

  const MyApp({
    super.key,
    required this.sharedPreferences,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    // Dependency injection - Clean Architecture
    final authLocalDataSource = AuthLocalDataSource(
      sharedPreferences: sharedPreferences,
    );
    
    final authRemoteDataSource = AuthRemoteDataSource(
      client: http.Client(),
      baseUrl: 'https://api.example.com',
    );
    
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );

    final productRemoteDataSource = ProductRemoteDataSource();
    final productLocalDataSource = ProductLocalDataSource();
    
    final productRepository = ProductRepositoryImpl(
      remoteDataSource: productRemoteDataSource,
      localDataSource: productLocalDataSource,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productRepository: productRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(sharedPreferences),
        ),
        ChangeNotifierProvider(
          create: (_) => BatchProvider(sharedPreferences),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(sharedPreferences),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppStrings.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? material.ThemeMode.dark : material.ThemeMode.light,
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return authProvider.isLoggedIn
                    ? const HomeScreen()
                    : const LoginScreen();
              },
            ),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
