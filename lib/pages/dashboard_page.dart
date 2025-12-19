import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_app/services/app_store.dart';
import 'package:shopping_list_app/widgets/common/app_header.dart';
import 'package:shopping_list_app/widgets/common/stats_widget.dart';
import 'package:shopping_list_app/widgets/common/gradient_button.dart';
import 'package:shopping_list_app/widgets/common/dashboard_toolbar.dart';
import 'package:shopping_list_app/widgets/common/list_card.dart';
import 'package:shopping_list_app/widgets/common/empty_state.dart';
import 'package:shopping_list_app/widgets/common/help_tooltip.dart';
import 'package:shopping_list_app/widgets/common/calendar_view.dart';
import 'package:shopping_list_app/widgets/modals/create_list_modal.dart';
import 'package:shopping_list_app/widgets/modals/edit_list_modal.dart';
import 'package:shopping_list_app/widgets/modals/share_list_modal.dart';
import 'package:shopping_list_app/widgets/modals/delete_confirm_modal.dart';
import 'package:shopping_list_app/utils/list_stats_calculator.dart';
import 'package:shopping_list_app/utils/list_filter_sort.dart';
import 'package:shopping_list_app/utils/responsive.dart';
import 'package:shopping_list_app/models/shopping_list.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _searchTerm = '';
  String _sortBy = 'default';
  String _filterBy = 'all';
  String _viewMode = 'grid';
  DateTime _currentDate = DateTime.now();
  bool _showCreateModal = false;
  ShoppingList? _editingList;
  ShoppingList? _sharingList;
  ShoppingList? _deletingList;

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<AppStore>(context);
    final lists = store.lists;
    final items = store.items;
    final responsive = Responsive.of(context);

    final listsWithStats = ListStatsCalculator.calculateForLists(lists, items);

    final filteredAndSortedLists = ListFilterAndSort.filterAndSort(
      lists: listsWithStats,
      filterBy: _filterBy,
      sortBy: _sortBy,
      searchTerm: _searchTerm,
    );

    return Stack(
      children: [
        Scaffold(
          body: Column(
            children: [
              const AppHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: responsive.padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      responsive.isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Списки покупок',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : const Color(0xFF111827),
                                            ),
                                      ),
                                    ),
                                    HelpTooltip(
                                      content:
                                          'Тут ви можете створювати та керувати своїми списками покупок. Кожен список може містити різні товари з цінами та кількістю.',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: GradientButton.icon(
                                    onPressed: () => {
                                      FirebaseAnalytics.instance.logEvent(
                                        name: 'create_list_dialog_opened',
                                      ),
                                      setState(() => _showCreateModal = true),
                                    },
                                    icon: Icons.add,
                                    label: 'Новий список',
                                    hint: '(N)',
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Списки покупок',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : const Color(0xFF111827),
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    HelpTooltip(
                                      content:
                                          'Тут ви можете створювати та керувати своїми списками покупок. Кожен список може містити різні товари з цінами та кількістю.',
                                    ),
                                  ],
                                ),
                                GradientButton.icon(
                                  onPressed: () => {
                                    FirebaseAnalytics.instance.logEvent(
                                      name: 'create_list_dialog_opened',
                                    ),
                                    setState(() => _showCreateModal = true),
                                  },
                                  icon: Icons.add,
                                  label: 'Новий список',
                                  hint: '(N)',
                                ),
                              ],
                            ),
                      SizedBox(height: responsive.spacing),

                      const StatsWidget(),
                      SizedBox(height: responsive.spacing),

                      DashboardToolbar(
                        searchTerm: _searchTerm,
                        sortBy: _sortBy,
                        filterBy: _filterBy,
                        viewMode: _viewMode,
                        onSearchChanged: (value) =>
                            setState(() => _searchTerm = value),
                        onSortChanged: (value) =>
                            setState(() => _sortBy = value),
                        onFilterChanged: (value) =>
                            setState(() => _filterBy = value),
                        onViewModeChanged: (value) =>
                            setState(() => _viewMode = value),
                        resultsCount: _searchTerm.isNotEmpty
                            ? filteredAndSortedLists.length
                            : null,
                      ),
                      SizedBox(height: responsive.spacing),

                      _viewMode == 'grid'
                          ? (filteredAndSortedLists.isEmpty
                                ? EmptyState(
                                    icon: Icons.shopping_cart_outlined,
                                    title:
                                        _searchTerm.isNotEmpty ||
                                            _filterBy != 'all'
                                        ? 'Нічого не знайдено'
                                        : 'Списків ще немає',
                                    subtitle:
                                        _searchTerm.isNotEmpty ||
                                            _filterBy != 'all'
                                        ? 'Спробуйте змінити фільтри'
                                        : 'Створіть перший список',
                                  )
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      final defaultColumns = 3;
                                      final crossAxisCount = responsive
                                          .getGridColumns(defaultColumns);
                                      final spacing = responsive.isMobile
                                          ? 12.0
                                          : 16.0;
                                      final width = responsive.isMobile
                                          ? constraints.maxWidth
                                          : (constraints.maxWidth -
                                                    (crossAxisCount - 1) *
                                                        spacing) /
                                                crossAxisCount;

                                      return Wrap(
                                        spacing: spacing,
                                        runSpacing: spacing,
                                        alignment: WrapAlignment.start,
                                        children: filteredAndSortedLists.map((
                                          listData,
                                        ) {
                                          return SizedBox(
                                            width: width,
                                            child: ListCard(
                                              listData: listData,
                                              onTap: () => context.go(
                                                '/list/${listData.list.id}',
                                              ),
                                              onEdit: () {
                                                setState(
                                                  () => _editingList =
                                                      listData.list,
                                                );
                                              },
                                              onShare: () {
                                                setState(
                                                  () => _sharingList =
                                                      listData.list,
                                                );
                                              },
                                              onDelete: () {
                                                setState(
                                                  () => _deletingList =
                                                      listData.list,
                                                );
                                              },
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ))
                          : CalendarView(
                              lists: filteredAndSortedLists,
                              currentDate: _currentDate,
                              onDateChanged: (date) =>
                                  setState(() => _currentDate = date),
                              onListTap: (listId) =>
                                  context.go('/list/$listId'),
                              onCreateList: (date) {
                                setState(() {
                                  _currentDate = date;
                                  _showCreateModal = true;
                                });
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => setState(() => _showCreateModal = true),
            child: const Icon(Icons.add),
          ),
        ),
        if (_showCreateModal)
          CreateListModal(
            onClose: () => setState(() => _showCreateModal = false),
          ),
        if (_editingList != null)
          EditListModal(
            list: _editingList!,
            onClose: () => setState(() => _editingList = null),
          ),
        if (_sharingList != null)
          ShareListModal(
            listId: _sharingList!.id,
            listName: _sharingList!.name,
            onClose: () => setState(() => _sharingList = null),
          ),
        if (_deletingList != null)
          DeleteConfirmModal(
            title: 'Підтвердження видалення',
            message:
                'Ви впевнені, що хочете видалити список "${_deletingList!.name}"? Цю дію неможливо скасувати.',
            onConfirm: () async {
              final store = Provider.of<AppStore>(context, listen: false);
              final listId = _deletingList!.id;
              final listName = _deletingList!.name;

              await store.removeList(listId);

              // Логування події видалення списку
              FirebaseAnalytics.instance.logEvent(
                name: 'list_deleted',
                parameters: {'list_id': listId, 'list_name': listName},
              );

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Список "$listName" видалено')),
              );
              if (!mounted) return;
              setState(() => _deletingList = null);
            },
            onCancel: () => setState(() => _deletingList = null),
          ),
      ],
    );
  }
}
