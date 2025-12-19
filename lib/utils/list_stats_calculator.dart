import 'package:shopping_list_app/models/shopping_list.dart';
import 'package:shopping_list_app/models/item.dart';

class ListStats {
  final int totalItems;
  final int purchasedItems;
  final int pendingItems;
  final double totalPrice;
  final double purchasedPrice;
  final bool isCompleted;

  const ListStats({
    required this.totalItems,
    required this.purchasedItems,
    required this.pendingItems,
    required this.totalPrice,
    required this.purchasedPrice,
    required this.isCompleted,
  });
}

class ListStatsCalculator {
  static ListStats calculate(ShoppingList list, List<Item> allItems) {
    final listItems = allItems.where((item) => item.listId == list.id).toList();
    final totalItems = listItems.length;
    final purchasedItems = listItems
        .where((i) => i.status == ItemStatus.purchased)
        .length;
    final pendingItems = totalItems - purchasedItems;
    final totalPrice = listItems.fold<double>(
      0,
      (sum, item) => sum + (item.price ?? 0),
    );
    final purchasedPrice = listItems
        .where((i) => i.status == ItemStatus.purchased)
        .fold<double>(0, (sum, item) => sum + (item.price ?? 0));
    final isCompleted = totalItems > 0 && purchasedItems == totalItems;

    return ListStats(
      totalItems: totalItems,
      purchasedItems: purchasedItems,
      pendingItems: pendingItems,
      totalPrice: totalPrice,
      purchasedPrice: purchasedPrice,
      isCompleted: isCompleted,
    );
  }

  static List<ListWithStats> calculateForLists(
    List<ShoppingList> lists,
    List<Item> allItems,
  ) {
    return lists.map((list) {
      final stats = calculate(list, allItems);
      return ListWithStats(list: list, stats: stats);
    }).toList();
  }
}

class ListWithStats {
  final ShoppingList list;
  final ListStats stats;

  const ListWithStats({
    required this.list,
    required this.stats,
  });
}

