import 'package:shopping_list_app/utils/list_stats_calculator.dart';

class ListFilterAndSort {
  static List<ListWithStats> filterAndSort({
    required List<ListWithStats> lists,
    required String filterBy,
    required String sortBy,
    String? searchTerm,
  }) {
    var filtered = [...lists];

    if (filterBy == 'active') {
      filtered = filtered.where((l) => !l.stats.isCompleted).toList();
    } else if (filterBy == 'completed') {
      filtered = filtered.where((l) => l.stats.isCompleted).toList();
    } else if (filterBy == 'overdue') {
      final now = DateTime.now();
      filtered = filtered.where((list) {
        if (list.stats.isCompleted) return false;
        if (list.list.dueDate == null) return false;
        return list.list.dueDate!.isBefore(now);
      }).toList();
    }

    if (searchTerm != null && searchTerm.trim().isNotEmpty) {
      final searchLower = searchTerm.toLowerCase();
      filtered = filtered.where((list) {
        return list.list.name.toLowerCase().contains(searchLower) ||
            (list.list.description?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }

    filtered.sort((a, b) {
      switch (sortBy) {
        case 'name-asc':
          return a.list.name.compareTo(b.list.name);
        case 'name-desc':
          return b.list.name.compareTo(a.list.name);
        case 'created-old':
          return a.list.createdAt.compareTo(b.list.createdAt);
        case 'due-soon':
          if (a.list.dueDate == null && b.list.dueDate == null) return 0;
          if (a.list.dueDate == null) return 1;
          if (b.list.dueDate == null) return -1;
          return a.list.dueDate!.compareTo(b.list.dueDate!);
        case 'due-late':
          if (a.list.dueDate == null && b.list.dueDate == null) return 0;
          if (a.list.dueDate == null) return 1;
          if (b.list.dueDate == null) return -1;
          return b.list.dueDate!.compareTo(a.list.dueDate!);
        case 'default':
        default:
          return b.list.createdAt.compareTo(a.list.createdAt);
      }
    });

    return filtered;
  }
}

