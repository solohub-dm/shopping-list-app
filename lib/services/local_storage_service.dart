import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_list_app/models/shopping_list.dart';
import 'package:shopping_list_app/models/item.dart';
import 'package:shopping_list_app/models/user.dart';
import 'package:shopping_list_app/models/session.dart';
import 'package:shopping_list_app/models/app_state.dart';
import 'package:flutter/foundation.dart';

/// Сервіс для збереження та завантаження локальних даних через SharedPreferences
class LocalStorageService {
  static const String _keyShoppingLists = 'shopping_lists';
  static const String _keyItems = 'items';
  static const String _keyUsers = 'users';
  static const String _keySession = 'session';
  static const String _keyTheme = 'theme';
  static const String _keyLanguage = 'language';

  /// Зберегти список покупок
  Future<void> saveShoppingLists(List<ShoppingList> lists) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = lists.map((list) => list.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_keyShoppingLists, jsonString);
      if (kDebugMode) {
        print('LocalStorageService: Saved ${lists.length} shopping lists');
      }
    } catch (e) {
      if (kDebugMode) {
        print('LocalStorageService: Error saving shopping lists: $e');
      }
      rethrow;
    }
  }

  /// Завантажити список покупок
  Future<List<ShoppingList>> loadShoppingLists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyShoppingLists);
      if (jsonString == null) {
        return [];
      }
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final lists = jsonList
          .map((json) => ShoppingList.fromJson(json as Map<String, dynamic>))
          .toList();
      if (kDebugMode) {
        print('LocalStorageService: Loaded ${lists.length} shopping lists');
      }
      return lists;
    } catch (e) {
      if (kDebugMode) {
        print('LocalStorageService: Error loading shopping lists: $e');
      }
      return [];
    }
  }

  /// Зберегти товари
  Future<void> saveItems(List<Item> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_keyItems, jsonString);
      if (kDebugMode) {
        print('LocalStorageService: Saved ${items.length} items');
      }
    } catch (e) {
      if (kDebugMode) {
        print('LocalStorageService: Error saving items: $e');
      }
      rethrow;
    }
  }

  /// Завантажити товари
  Future<List<Item>> loadItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyItems);
      if (jsonString == null) {
        return [];
      }
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final items = jsonList
          .map((json) => Item.fromJson(json as Map<String, dynamic>))
          .toList();
      if (kDebugMode) {
        print('LocalStorageService: Loaded ${items.length} items');
      }
      return items;
    } catch (e) {
      if (kDebugMode) {
        print('LocalStorageService: Error loading items: $e');
      }
      return [];
    }
  }

  /// Зберегти користувачів
  Future<void> saveUsers(List<User> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = users.map((user) => user.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_keyUsers, jsonString);
      if (kDebugMode) {
        print('LocalStorageService: Saved ${users.length} users');
      }
    } catch (e) {
      if (kDebugMode) {
        print('LocalStorageService: Error saving users: $e');
      }
      rethrow;
    }
  }

  /// Завантажити користувачів
  Future<List<User>> loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyUsers);
      if (jsonString == null) {
        return [];
      }
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final users = jsonList
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
      if (kDebugMode) {
        print('LocalStorageService: Loaded ${users.length} users');
      }
      return users;
    } catch (e) {
      if (kDebugMode) {
        print('LocalStorageService: Error loading users: $e');
      }
      return [];
    }
  }

  /// Зберегти сесію
  Future<void> saveSession(Session session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(session.toJson());
      await prefs.setString(_keySession, jsonString);
      if (kDebugMode) {
        print('LocalStorageService: Saved session');
      }
    } catch (e) {
      if (kDebugMode) {
        print('LocalStorageService: Error saving session: $e');
      }
      rethrow;
    }
  }

  /// Завантажити сесію
  Future<Session> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keySession);
      if (jsonString == null) {
        return Session();
      }
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final session = Session.fromJson(json);
      if (kDebugMode) {
        print('LocalStorageService: Loaded session');
      }
      return session;
    } catch (e) {
      if (kDebugMode) {
        print('LocalStorageService: Error loading session: $e');
      }
      return Session();
    }
  }

  /// Зберегти тему
  Future<void> saveTheme(AppThemeMode theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyTheme, theme.name);
      if (kDebugMode) {
        print('LocalStorageService: Saved theme: ${theme.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('LocalStorageService: Error saving theme: $e');
      }
      rethrow;
    }
  }

  /// Завантажити тему
  Future<AppThemeMode> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_keyTheme);
      if (themeString == null) {
        return AppThemeMode.light;
      }
      final theme = AppThemeMode.values.firstWhere(
        (e) => e.name == themeString,
        orElse: () => AppThemeMode.light,
      );
      if (kDebugMode) {
        print('LocalStorageService: Loaded theme: ${theme.name}');
      }
      return theme;
    } catch (e) {
      if (kDebugMode) {
        print('LocalStorageService: Error loading theme: $e');
      }
      return AppThemeMode.light;
    }
  }

  /// Зберегти мову
  Future<void> saveLanguage(Language language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLanguage, language.name);
      if (kDebugMode) {
        print('LocalStorageService: Saved language: ${language.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('LocalStorageService: Error saving language: $e');
      }
      rethrow;
    }
  }

  /// Завантажити мову
  Future<Language> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageString = prefs.getString(_keyLanguage);
      if (languageString == null) {
        return Language.uk;
      }
      final language = Language.values.firstWhere(
        (e) => e.name == languageString,
        orElse: () => Language.uk,
      );
      if (kDebugMode) {
        print('LocalStorageService: Loaded language: ${language.name}');
      }
      return language;
    } catch (e) {
      if (kDebugMode) {
        print('LocalStorageService: Error loading language: $e');
      }
      return Language.uk;
    }
  }

  /// Очистити всі збережені дані
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (kDebugMode) {
        print('LocalStorageService: Cleared all data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('LocalStorageService: Error clearing data: $e');
      }
      rethrow;
    }
  }
}

