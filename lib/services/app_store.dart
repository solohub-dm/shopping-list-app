import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shopping_list_app/models/app_state.dart';
import 'package:shopping_list_app/models/user.dart';
import 'package:shopping_list_app/models/shopping_list.dart';
import 'package:shopping_list_app/models/item.dart';
import 'package:shopping_list_app/models/category.dart' as models;
import 'package:shopping_list_app/models/session.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shopping_list_app/services/local_storage_service.dart';
import 'package:shopping_list_app/services/firestore_service.dart';

class AppStore extends ChangeNotifier {
  final _uuid = const Uuid();
  final _localStorage = LocalStorageService();
  final _firestore = FirestoreService();
  bool _isLoading = true;

  AppState _state = AppState(
    theme: AppThemeMode.light,
    session: Session(),
    users: [],
    lists: [],
    items: [],
    categories: _defaultCategories,
    offline: false,
    language: Language.uk,
  );

  AppState get state => _state;
  bool get isLoading => _isLoading;

  AppThemeMode get theme => _state.theme;
  Session get session => _state.session;
  List<User> get users => _state.users;
  List<ShoppingList> get lists => _state.lists;
  List<Item> get items => _state.items;
  List<models.Category> get categories => _state.categories;
  String? get currentListId => _state.currentListId;
  bool get offline => _state.offline;
  Language get language => _state.language;

  /// Завантажити дані з Firestore (з fallback на локальне сховище)
  /// Optionally uses the current state's session if available
  Future<void> loadData({Session? session}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use provided session or load from LocalStorage
      final loadedSession = session ?? await _localStorage.loadSession();
      final loadedTheme = await _localStorage.loadTheme();
      final loadedLanguage = await _localStorage.loadLanguage();

      // Initialize with empty data - only load user-specific data if logged in
      List<User> users = [];
      List<ShoppingList> lists = [];
      List<Item> items = [];

      // Only load user-specific data if user is logged in
      if (loadedSession.userId != null) {
        try {
          // Load user's lists from Firestore
          lists = await _firestore.getLists(loadedSession.userId!);

          // Load items for the user's lists
          if (lists.isNotEmpty) {
            final listIds = lists.map((list) => list.id).toList();
            items = await _firestore.getItems(listIds);
          }

          if (kDebugMode) {
            print(
              'AppStore: Loaded from Firestore - ${lists.length} lists, ${items.length} items for user ${loadedSession.userId}',
            );
          }

          // Cache to LocalStorage (filtered by userId)
          await _localStorage.saveShoppingLists(lists);
          await _localStorage.saveItems(items);
        } catch (firestoreError) {
          if (kDebugMode) {
            print(
              'AppStore: Firestore error, falling back to LocalStorage: $firestoreError',
            );
          }
          // Fallback to LocalStorage - but only load user's data
          final allLocalLists = await _localStorage.loadShoppingLists();
          final allLocalItems = await _localStorage.loadItems();

          // Filter to only this user's lists
          lists = allLocalLists
              .where((list) => list.ownerId == loadedSession.userId)
              .toList();
          final listIds = lists.map((list) => list.id).toList();
          items = allLocalItems
              .where((item) => listIds.contains(item.listId))
              .toList();

          setOffline(true);
        }
      }

      _state = _state.copyWith(
        users: users,
        lists: lists,
        items: items,
        session: loadedSession,
        theme: loadedTheme,
        language: loadedLanguage,
      );

      if (kDebugMode) {
        print('AppStore: Data loaded successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStore: Error loading data: $e');
      }
      // In case of error, use empty data
      _state = _state.copyWith(users: [], lists: [], items: []);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setTheme(AppThemeMode theme) {
    _state = _state.copyWith(theme: theme);
    _localStorage.saveTheme(theme);
    notifyListeners();
  }

  void setLanguage(Language language) {
    _state = _state.copyWith(language: language);
    _localStorage.saveLanguage(language);
    notifyListeners();
  }

  Future<void> login(Session session) async {
    // Update session in state and storage
    _state = _state.copyWith(session: session);
    await _localStorage.saveSession(session);
    notifyListeners();

    // Set Firebase Analytics user property for user segment
    try {
      final user = _state.users.firstWhere((u) => u.id == session.userId);
      // Use the .name property of the enum (e.g. "personal", "corporate")
      FirebaseAnalytics.instance.setUserProperty(
        name: 'user_segment',
        value: user.segment.name,
      );
      if (kDebugMode) {
        print('Firebase Analytics: Set user_segment = ${user.segment.name}');
      }
    } catch (e) {
      // User not found in local store, skip setting user property
      if (kDebugMode) {
        print(
          'Firebase Analytics: User ${session.userId} not found in local store, cannot set user_segment',
        );
      }
    }

    // Immediately load data for the logged-in user
    await loadData(session: session);
  }

  void logout() {
    // Clear all user-specific data on logout
    _state = _state.copyWith(
      session: Session(),
      users: [],
      lists: [],
      items: [],
      currentListId: null,
    );
    _localStorage.saveSession(Session());
    _localStorage.saveUsers([]);
    _localStorage.saveShoppingLists([]);
    _localStorage.saveItems([]);

    // Notify listeners immediately so UI updates
    notifyListeners();

    // Clear Firebase Analytics user property on logout
    FirebaseAnalytics.instance.setUserProperty(
      name: 'user_segment',
      value: null,
    );

    if (kDebugMode) {
      print('AppStore: User logged out, all data cleared');
    }
  }

  Future<String> addUser({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    String? password,
    required UserSegment segment,
  }) async {
    final now = DateTime.now();
    final newUser = User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      segment: segment,
      createdAt: now,
    );
    _state = _state.copyWith(users: [..._state.users, newUser]);

    // Save to Firestore and LocalStorage
    try {
      await _firestore.addUser(newUser);
      await _localStorage.saveUsers(_state.users);
    } catch (e) {
      if (kDebugMode) {
        print('AppStore: Error saving user to Firestore: $e');
      }
      // Still save to LocalStorage as fallback
      await _localStorage.saveUsers(_state.users);
    }

    notifyListeners();

    // Set Firebase Analytics user property for user segment after registration
    // Use the .name property of the enum (e.g. "personal", "corporate")
    FirebaseAnalytics.instance.setUserProperty(
      name: 'user_segment',
      value: newUser.segment.name,
    );
    if (kDebugMode) {
      print(
        'Firebase Analytics: Set user_segment = ${newUser.segment.name} for new user ${newUser.id}',
      );
    }

    return id;
  }

  Future<void> updateUser(User user) async {
    _state = _state.copyWith(
      users: _state.users.map((u) => u.id == user.id ? user : u).toList(),
    );

    // Save to Firestore and LocalStorage
    try {
      await _firestore.updateUser(user);
      await _localStorage.saveUsers(_state.users);
    } catch (e) {
      if (kDebugMode) {
        print('AppStore: Error updating user in Firestore: $e');
      }
      // Still save to LocalStorage as fallback
      await _localStorage.saveUsers(_state.users);
    }

    notifyListeners();
  }

  Future<String> addList({
    required String ownerId,
    required String name,
    String? description,
    String? color,
    List<String>? participants,
    DateTime? dueDate,
    bool archived = false,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final newList = ShoppingList(
      id: id,
      ownerId: ownerId,
      name: name,
      description: description,
      color: color,
      participants: participants ?? [],
      createdAt: now,
      updatedAt: now,
      dueDate: dueDate,
      archived: archived,
    );
    _state = _state.copyWith(lists: [..._state.lists, newList]);

    // Save to Firestore and LocalStorage
    try {
      await _firestore.addList(newList);
      await _localStorage.saveShoppingLists(_state.lists);
    } catch (e) {
      if (kDebugMode) {
        print('AppStore: Error saving list to Firestore: $e');
      }
      // Still save to LocalStorage as fallback
      await _localStorage.saveShoppingLists(_state.lists);
    }

    notifyListeners();
    return id;
  }

  Future<void> updateList(ShoppingList list) async {
    final updatedList = list.copyWith(updatedAt: DateTime.now());
    _state = _state.copyWith(
      lists: _state.lists
          .map((l) => l.id == list.id ? updatedList : l)
          .toList(),
    );

    // Save to Firestore and LocalStorage
    try {
      await _firestore.updateList(updatedList);
      await _localStorage.saveShoppingLists(_state.lists);
    } catch (e) {
      if (kDebugMode) {
        print('AppStore: Error updating list in Firestore: $e');
      }
      // Still save to LocalStorage as fallback
      await _localStorage.saveShoppingLists(_state.lists);
    }

    notifyListeners();
  }

  Future<void> removeList(String id) async {
    _state = _state.copyWith(
      lists: _state.lists.where((l) => l.id != id).toList(),
      items: _state.items.where((i) => i.listId != id).toList(),
    );

    // Delete from Firestore and LocalStorage
    try {
      await _firestore.deleteList(id);
      await _firestore.deleteItemsByListId(id);
      await _localStorage.saveShoppingLists(_state.lists);
      await _localStorage.saveItems(_state.items);
    } catch (e) {
      if (kDebugMode) {
        print('AppStore: Error deleting list from Firestore: $e');
      }
      // Still save to LocalStorage as fallback
      await _localStorage.saveShoppingLists(_state.lists);
      await _localStorage.saveItems(_state.items);
    }

    notifyListeners();
  }

  Future<({ShoppingList list, List<Item> items})> softDeleteList(
    String id,
  ) async {
    final list = _state.lists.firstWhere((l) => l.id == id);
    final items = _state.items.where((i) => i.listId == id).toList();

    _state = _state.copyWith(
      lists: _state.lists.where((l) => l.id != id).toList(),
      items: _state.items.where((i) => i.listId != id).toList(),
    );

    // Delete from Firestore and LocalStorage
    try {
      await _firestore.deleteList(id);
      await _firestore.deleteItemsByListId(id);
      await _localStorage.saveShoppingLists(_state.lists);
      await _localStorage.saveItems(_state.items);
    } catch (e) {
      if (kDebugMode) {
        print('AppStore: Error soft deleting list from Firestore: $e');
      }
      // Still save to LocalStorage as fallback
      await _localStorage.saveShoppingLists(_state.lists);
      await _localStorage.saveItems(_state.items);
    }

    notifyListeners();

    return (list: list, items: items);
  }

  Future<void> restoreList(ShoppingList list, List<Item> items) async {
    _state = _state.copyWith(
      lists: [..._state.lists, list],
      items: [..._state.items, ...items],
    );

    // Save to Firestore and LocalStorage
    try {
      await _firestore.addList(list);
      for (final item in items) {
        await _firestore.addItem(item);
      }
      await _localStorage.saveShoppingLists(_state.lists);
      await _localStorage.saveItems(_state.items);
    } catch (e) {
      if (kDebugMode) {
        print('AppStore: Error restoring list to Firestore: $e');
      }
      // Still save to LocalStorage as fallback
      await _localStorage.saveShoppingLists(_state.lists);
      await _localStorage.saveItems(_state.items);
    }

    notifyListeners();
  }

  Future<String> addItem({
    required String listId,
    required String name,
    required double quantity,
    required Unit unit,
    double? price,
    String? categoryId,
    ItemStatus status = ItemStatus.pending,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final newItem = Item(
      id: id,
      listId: listId,
      name: name,
      quantity: quantity,
      unit: unit,
      price: price,
      categoryId: categoryId,
      status: status,
      createdAt: now,
      purchasedAt: status == ItemStatus.purchased ? now : null,
    );
    _state = _state.copyWith(items: [..._state.items, newItem]);

    // Save to Firestore and LocalStorage
    try {
      await _firestore.addItem(newItem);
      await _localStorage.saveItems(_state.items);
    } catch (e) {
      if (kDebugMode) {
        print('AppStore: Error saving item to Firestore: $e');
      }
      // Still save to LocalStorage as fallback
      await _localStorage.saveItems(_state.items);
    }

    notifyListeners();
    return id;
  }

  Future<void> updateItem(Item item) async {
    _state = _state.copyWith(
      items: _state.items.map((i) => i.id == item.id ? item : i).toList(),
    );

    // Save to Firestore and LocalStorage
    try {
      await _firestore.updateItem(item);
      await _localStorage.saveItems(_state.items);
    } catch (e) {
      if (kDebugMode) {
        print('AppStore: Error updating item in Firestore: $e');
      }
      // Still save to LocalStorage as fallback
      await _localStorage.saveItems(_state.items);
    }

    notifyListeners();
  }

  Future<void> removeItem(String id) async {
    _state = _state.copyWith(
      items: _state.items.where((i) => i.id != id).toList(),
    );

    // Delete from Firestore and LocalStorage
    try {
      await _firestore.deleteItem(id);
      await _localStorage.saveItems(_state.items);
    } catch (e) {
      if (kDebugMode) {
        print('AppStore: Error deleting item from Firestore: $e');
      }
      // Still save to LocalStorage as fallback
      await _localStorage.saveItems(_state.items);
    }

    notifyListeners();
  }

  Future<Item?> softDeleteItem(String id) async {
    final item = _state.items.firstWhere((i) => i.id == id);
    _state = _state.copyWith(
      items: _state.items.where((i) => i.id != id).toList(),
    );

    // Delete from Firestore and LocalStorage
    try {
      await _firestore.deleteItem(id);
      await _localStorage.saveItems(_state.items);
    } catch (e) {
      if (kDebugMode) {
        print('AppStore: Error soft deleting item from Firestore: $e');
      }
      // Still save to LocalStorage as fallback
      await _localStorage.saveItems(_state.items);
    }

    notifyListeners();
    return item;
  }

  Future<void> restoreItem(Item item) async {
    _state = _state.copyWith(items: [..._state.items, item]);

    // Save to Firestore and LocalStorage
    try {
      await _firestore.addItem(item);
      await _localStorage.saveItems(_state.items);
    } catch (e) {
      if (kDebugMode) {
        print('AppStore: Error restoring item to Firestore: $e');
      }
      // Still save to LocalStorage as fallback
      await _localStorage.saveItems(_state.items);
    }

    notifyListeners();
  }

  void setCurrentList(String? id) {
    _state = _state.copyWith(currentListId: id);
    notifyListeners();
  }

  void setOffline(bool offline) {
    _state = _state.copyWith(offline: offline);
    notifyListeners();
  }

  Future<void> syncNow() async {
    if (_state.session.userId == null) {
      if (kDebugMode) {
        print('AppStore: Cannot sync - no user logged in');
      }
      return;
    }

    try {
      // Sync only user-specific data to Firestore
      for (final list in _state.lists) {
        // Ensure ownerId matches current user
        if (list.ownerId == _state.session.userId) {
          await _firestore.addList(list);
        }
      }

      // Get list IDs for current user's lists
      final userListIds = _state.lists
          .where((list) => list.ownerId == _state.session.userId)
          .map((list) => list.id)
          .toList();

      // Sync only items that belong to user's lists
      for (final item in _state.items) {
        if (userListIds.contains(item.listId)) {
          await _firestore.addItem(item);
        }
      }

      // Also update LocalStorage
      await _localStorage.saveShoppingLists(_state.lists);
      await _localStorage.saveItems(_state.items);

      setOffline(false);

      if (kDebugMode) {
        print('AppStore: Sync completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStore: Error during sync: $e');
      }
      setOffline(true);
    }
  }
}

final _defaultCategories = [
  models.Category(
    id: 'groceries',
    nameUk: 'Продукти',
    nameEn: 'Groceries',
    icon: 'ShoppingBasket',
    color: 'bg-green-500',
  ),
  models.Category(
    id: 'household',
    nameUk: 'Побут',
    nameEn: 'Household',
    icon: 'Home',
    color: 'bg-blue-500',
  ),
  models.Category(
    id: 'other',
    nameUk: 'Інше',
    nameEn: 'Other',
    icon: 'Package',
    color: 'bg-gray-500',
  ),
];
