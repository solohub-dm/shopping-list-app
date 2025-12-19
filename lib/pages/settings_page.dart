import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list_app/services/app_store.dart';
import 'package:shopping_list_app/models/app_state.dart' as models;
import 'package:shopping_list_app/widgets/common/app_header.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<AppStore>(context);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Налаштування',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('Тема'),
                            subtitle: const Text('Світла або темна'),
                            trailing: DropdownButton<models.AppThemeMode>(
                              value: store.theme,
                              items: const [
                                DropdownMenuItem(
                                  value: models.AppThemeMode.light,
                                  child: Text('Світла'),
                                ),
                                DropdownMenuItem(
                                  value: models.AppThemeMode.dark,
                                  child: Text('Темна'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  try {
                                    throw Exception(
                                      'Тестова некритична помилка при зміні теми: ${value.name}',
                                    );
                                  } catch (e, stackTrace) {
                                    FirebaseCrashlytics.instance.recordError(
                                      e,
                                      stackTrace,
                                      reason:
                                          'Тестування Crashlytics: зміна теми',
                                      fatal: false,
                                    );
                                  }

                                  store.setTheme(value);
                                }
                              },
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Мова'),
                            subtitle: const Text('Українська/English (демо)'),
                            trailing: DropdownButton<models.Language>(
                              value: store.language,
                              items: const [
                                DropdownMenuItem(
                                  value: models.Language.uk,
                                  child: Text('Українська'),
                                ),
                                DropdownMenuItem(
                                  value: models.Language.en,
                                  child: Text('English'),
                                ),
                              ],
                              onChanged: (value) {
                                try {
                                  throw Exception(
                                    'Це тестова помилка для Crashlytics (Web)',
                                  );
                                } catch (e) {
                                  FirebaseCrashlytics.instance.crash();
                                }
                                // if (value != null) {
                                //   store.setLanguage(value);
                                // }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
