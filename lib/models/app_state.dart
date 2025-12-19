import 'package:shopping_list_app/models/user.dart';
import 'package:shopping_list_app/models/shopping_list.dart';
import 'package:shopping_list_app/models/item.dart';
import 'package:shopping_list_app/models/category.dart' as models;
import 'package:shopping_list_app/models/session.dart';

enum AppThemeMode { light, dark }

enum Language { uk, en }

class AppState {
  final AppThemeMode theme;
  final Session session;
  final List<User> users;
  final List<ShoppingList> lists;
  final List<Item> items;
  final List<models.Category> categories;
  final String? currentListId;
  final bool offline;
  final Language language;

  AppState({
    required this.theme,
    required this.session,
    required this.users,
    required this.lists,
    required this.items,
    required this.categories,
    this.currentListId,
    required this.offline,
    required this.language,
  });

  AppState copyWith({
    AppThemeMode? theme,
    Session? session,
    List<User>? users,
    List<ShoppingList>? lists,
    List<Item>? items,
    List<models.Category>? categories,
    String? currentListId,
    bool? offline,
    Language? language,
  }) {
    return AppState(
      theme: theme ?? this.theme,
      session: session ?? this.session,
      users: users ?? this.users,
      lists: lists ?? this.lists,
      items: items ?? this.items,
      categories: categories ?? this.categories,
      currentListId: currentListId ?? this.currentListId,
      offline: offline ?? this.offline,
      language: language ?? this.language,
    );
  }
}

