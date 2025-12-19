import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shopping_list_app/models/user.dart';
import 'package:shopping_list_app/models/shopping_list.dart';
import 'package:shopping_list_app/models/item.dart';

/// Service for managing Firestore operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String _usersCollection = 'users';
  static const String _shoppingListsCollection = 'shopping_lists';
  static const String _itemsCollection = 'items';

  // ==================== USERS ====================

  /// Add a new user to Firestore
  /// Uses userId as document ID
  Future<void> addUser(User user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(user.toJson());
      if (kDebugMode) {
        print('FirestoreService: Added user ${user.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirestoreService: Error adding user: $e');
      }
      rethrow;
    }
  }

  /// Get a user by ID
  Future<User?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();
      if (!doc.exists) {
        return null;
      }
      return User.fromJson(doc.data()!);
    } catch (e) {
      if (kDebugMode) {
        print('FirestoreService: Error getting user: $e');
      }
      return null;
    }
  }

  /// Get all users as a stream
  Stream<List<User>> getUsersStream() {
    return _firestore
        .collection(_usersCollection)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => User.fromJson(doc.data())).toList(),
        );
  }

  /// Get all users as a future
  Future<List<User>> getUsers() async {
    try {
      final snapshot = await _firestore.collection(_usersCollection).get();
      return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
    } catch (e) {
      if (kDebugMode) {
        print('FirestoreService: Error getting users: $e');
      }
      return [];
    }
  }

  /// Update a user
  Future<void> updateUser(User user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .update(user.toJson());
      if (kDebugMode) {
        print('FirestoreService: Updated user ${user.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirestoreService: Error updating user: $e');
      }
      rethrow;
    }
  }

  /// Delete a user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();
      if (kDebugMode) {
        print('FirestoreService: Deleted user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirestoreService: Error deleting user: $e');
      }
      rethrow;
    }
  }

  // ==================== SHOPPING LISTS ====================

  /// Add a new shopping list to Firestore
  /// Uses listId as document ID
  Future<void> addList(ShoppingList list) async {
    try {
      await _firestore
          .collection(_shoppingListsCollection)
          .doc(list.id)
          .set(list.toJson());
      if (kDebugMode) {
        print('FirestoreService: Added list ${list.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirestoreService: Error adding list: $e');
      }
      rethrow;
    }
  }

  /// Get a shopping list by ID
  Future<ShoppingList?> getList(String listId) async {
    try {
      final doc = await _firestore
          .collection(_shoppingListsCollection)
          .doc(listId)
          .get();
      if (!doc.exists) {
        return null;
      }
      return ShoppingList.fromJson(doc.data()!);
    } catch (e) {
      if (kDebugMode) {
        print('FirestoreService: Error getting list: $e');
      }
      return null;
    }
  }

  /// Get all shopping lists as a stream for a specific user
  Stream<List<ShoppingList>> getListsStream(String userId) {
    return _firestore
        .collection(_shoppingListsCollection)
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    ShoppingList.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  /// Get all shopping lists as a future for a specific user
  Future<List<ShoppingList>> getLists(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_shoppingListsCollection)
          .where('ownerId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map(
            (doc) => ShoppingList.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('FirestoreService: Error getting lists: $e');
      }
      return [];
    }
  }

  /// Update a shopping list
  Future<void> updateList(ShoppingList list) async {
    try {
      await _firestore
          .collection(_shoppingListsCollection)
          .doc(list.id)
          .update(list.toJson());
      if (kDebugMode) {
        print('FirestoreService: Updated list ${list.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirestoreService: Error updating list: $e');
      }
      rethrow;
    }
  }

  /// Delete a shopping list
  Future<void> deleteList(String listId) async {
    try {
      await _firestore
          .collection(_shoppingListsCollection)
          .doc(listId)
          .delete();
      if (kDebugMode) {
        print('FirestoreService: Deleted list $listId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirestoreService: Error deleting list: $e');
      }
      rethrow;
    }
  }

  // ==================== ITEMS ====================

  /// Add a new item to Firestore
  /// Uses itemId as document ID
  Future<void> addItem(Item item) async {
    try {
      await _firestore
          .collection(_itemsCollection)
          .doc(item.id)
          .set(item.toJson());
      if (kDebugMode) {
        print('FirestoreService: Added item ${item.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirestoreService: Error adding item: $e');
      }
      rethrow;
    }
  }

  /// Get an item by ID
  Future<Item?> getItem(String itemId) async {
    try {
      final doc = await _firestore
          .collection(_itemsCollection)
          .doc(itemId)
          .get();
      if (!doc.exists) {
        return null;
      }
      return Item.fromJson(doc.data()!);
    } catch (e) {
      if (kDebugMode) {
        print('FirestoreService: Error getting item: $e');
      }
      return null;
    }
  }

  /// Get all items as a stream for specific list IDs
  Stream<List<Item>> getItemsStream(List<String> listIds) {
    if (listIds.isEmpty) {
      return Stream.value([]);
    }

    // Firestore 'whereIn' supports up to 10 items, so we need to batch if more
    if (listIds.length <= 10) {
      return _firestore
          .collection(_itemsCollection)
          .where('listId', whereIn: listIds)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => Item.fromJson(doc.data() as Map<String, dynamic>))
                .toList(),
          );
    } else {
      // For more than 10 lists, combine results from multiple queries
      // Note: This creates multiple streams that need to be combined
      // For simplicity, we'll limit to first 10 lists in stream mode
      // In production, consider using a different approach or pagination
      final limitedListIds = listIds.take(10).toList();
      return _firestore
          .collection(_itemsCollection)
          .where('listId', whereIn: limitedListIds)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => Item.fromJson(doc.data() as Map<String, dynamic>))
                .toList(),
          );
    }
  }

  /// Get all items as a future for specific list IDs
  Future<List<Item>> getItems(List<String> listIds) async {
    if (listIds.isEmpty) {
      return [];
    }

    try {
      // Firestore 'whereIn' supports up to 10 items, so we need to batch if more
      if (listIds.length <= 10) {
        final snapshot = await _firestore
            .collection(_itemsCollection)
            .where('listId', whereIn: listIds)
            .get();

        return snapshot.docs
            .map((doc) => Item.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      } else {
        // For more than 10 lists, batch the queries
        final allItems = <Item>[];
        for (var i = 0; i < listIds.length; i += 10) {
          final batch = listIds.sublist(
            i,
            (i + 10 > listIds.length) ? listIds.length : i + 10,
          );
          final snapshot = await _firestore
              .collection(_itemsCollection)
              .where('listId', whereIn: batch)
              .get();

          final items = snapshot.docs
              .map((doc) => Item.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
          allItems.addAll(items);
        }
        return allItems;
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirestoreService: Error getting items: $e');
      }
      return [];
    }
  }

  /// Update an item
  Future<void> updateItem(Item item) async {
    try {
      await _firestore
          .collection(_itemsCollection)
          .doc(item.id)
          .update(item.toJson());
      if (kDebugMode) {
        print('FirestoreService: Updated item ${item.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirestoreService: Error updating item: $e');
      }
      rethrow;
    }
  }

  /// Delete an item
  Future<void> deleteItem(String itemId) async {
    try {
      await _firestore.collection(_itemsCollection).doc(itemId).delete();
      if (kDebugMode) {
        print('FirestoreService: Deleted item $itemId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirestoreService: Error deleting item: $e');
      }
      rethrow;
    }
  }

  /// Delete all items for a specific list
  Future<void> deleteItemsByListId(String listId) async {
    try {
      final snapshot = await _firestore
          .collection(_itemsCollection)
          .where('listId', isEqualTo: listId)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (kDebugMode) {
        print(
          'FirestoreService: Deleted ${snapshot.docs.length} items for list $listId',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirestoreService: Error deleting items by listId: $e');
      }
      rethrow;
    }
  }
}
