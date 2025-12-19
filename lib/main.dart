import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list_app/services/app_store.dart';
import 'package:shopping_list_app/utils/theme.dart';
import 'package:shopping_list_app/utils/router.dart';
import 'package:shopping_list_app/models/app_state.dart' as models;
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('uk_UA', null);
  await initializeDateFormatting('en_US', null);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    // Enable debug mode for Firebase Analytics DebugView
    // This allows events to appear in Firebase Console DebugView
  }

  runApp(const MyApp());
}

final GoRouter _router = AppRouter.getRouter();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final store = AppStore();
        // Завантажуємо дані при створенні AppStore
        store.loadData();
        return store;
      },
      child: Consumer<AppStore>(
        builder: (context, store, _) {
          // Показуємо індикатор завантаження, поки дані завантажуються
          if (store.isLoading) {
            return MaterialApp(
              title: 'Менеджер покупок',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.getLightTheme(),
              darkTheme: AppTheme.getDarkTheme(),
              home: const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          return MaterialApp.router(
            title: 'Менеджер покупок',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getLightTheme(),
            darkTheme: AppTheme.getDarkTheme(),
            themeMode: store.theme == models.AppThemeMode.light
                ? ThemeMode.light
                : ThemeMode.dark,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
