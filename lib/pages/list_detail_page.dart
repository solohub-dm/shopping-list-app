import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_app/services/app_store.dart';
import 'package:shopping_list_app/models/item.dart';
import 'package:shopping_list_app/models/shopping_list.dart';
import 'package:shopping_list_app/widgets/common/app_header.dart';
import 'package:shopping_list_app/widgets/common/gradient_button.dart';
import 'package:shopping_list_app/widgets/common/search_field.dart';
import 'package:shopping_list_app/widgets/common/sort_dropdown.dart';
import 'package:shopping_list_app/widgets/common/filter_buttons.dart';
import 'package:shopping_list_app/widgets/common/empty_state.dart';
import 'package:shopping_list_app/widgets/modals/add_item_modal.dart';
import 'package:shopping_list_app/widgets/modals/edit_item_modal.dart';
import 'package:shopping_list_app/widgets/modals/edit_list_modal.dart';
import 'package:shopping_list_app/widgets/modals/share_list_modal.dart';
import 'package:shopping_list_app/widgets/modals/delete_confirm_modal.dart';
import 'package:shopping_list_app/utils/color_utils.dart';
import 'package:shopping_list_app/utils/app_constants.dart';
import 'package:shopping_list_app/utils/responsive.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class ListDetailPage extends StatefulWidget {
  final String listId;

  const ListDetailPage({super.key, required this.listId});

  @override
  State<ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  String _searchTerm = '';
  String _sortBy = 'default';
  String _filterBy = 'all';
  bool _showAddModal = false;
  Item? _editingItem;
  bool _showEditListModal = false;
  bool _showShareModal = false;
  bool _showDeleteItemConfirm = false;
  Item? _itemToDelete;
  ShoppingList? _cachedList;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = Provider.of<AppStore>(context, listen: false);
      final list = store.lists.where((l) => l.id == widget.listId).firstOrNull;
      if (list != null) {
        _cachedList = list;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    return Consumer<AppStore>(
      builder: (context, store, _) {
        ShoppingList? list = _cachedList;

        if (_cachedList != null && _cachedList!.id == widget.listId) {
          list = _cachedList;
          final storeList = store.lists
              .where((l) => l.id == widget.listId)
              .firstOrNull;
          if (storeList != null) {
            _cachedList = storeList;
            list = storeList;
          }
        } else {
          list = store.lists.where((l) => l.id == widget.listId).firstOrNull;
          if (list != null) {
            _cachedList = list;
          }
        }

        if (list == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final finalList = list;

        final items = store.items
            .where((i) => i.listId == widget.listId)
            .toList();

        var filteredItems = [...items];

        if (_filterBy == 'pending') {
          filteredItems = filteredItems
              .where((i) => i.status == ItemStatus.pending)
              .toList();
        } else if (_filterBy == 'purchased') {
          filteredItems = filteredItems
              .where((i) => i.status == ItemStatus.purchased)
              .toList();
        }

        if (_searchTerm.trim().isNotEmpty) {
          final searchLower = _searchTerm.toLowerCase();
          filteredItems = filteredItems
              .where((i) => i.name.toLowerCase().contains(searchLower))
              .toList();
        }

        filteredItems.sort((a, b) {
          switch (_sortBy) {
            case 'name-asc':
              return a.name.compareTo(b.name);
            case 'name-desc':
              return b.name.compareTo(a.name);
            case 'price-asc':
              return ((a.price ?? 0) - (b.price ?? 0)).toInt();
            case 'price-desc':
              return ((b.price ?? 0) - (a.price ?? 0)).toInt();
            case 'quantity-asc':
              return (a.quantity - b.quantity).toInt();
            case 'quantity-desc':
              return (b.quantity - a.quantity).toInt();
            case 'date-old':
              return a.createdAt.compareTo(b.createdAt);
            default:
              return b.createdAt.compareTo(a.createdAt);
          }
        });

        final purchased = items
            .where((i) => i.status == ItemStatus.purchased)
            .length;
        final totalPrice = items.fold<double>(
          0,
          (sum, item) => sum + (item.price ?? 0),
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
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () => context.go('/'),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Назад до списків'),
                              ),
                            ],
                          ),
                          SizedBox(height: responsive.spacing),
                          responsive.isMobile
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            finalList.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        if (finalList.color != null)
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: ColorUtils.parseColor(
                                                finalList.color!,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: responsive.spacing),
                                    SizedBox(
                                      width: double.infinity,
                                      child: GradientButton.icon(
                                        onPressed: () {
                                          // Логування події відкриття форми створення айтема
                                          FirebaseAnalytics.instance.logEvent(
                                            name: 'create_item_dialog_opened',
                                            parameters: {
                                              'list_id': widget.listId,
                                            },
                                          );
                                          setState(() => _showAddModal = true);
                                        },
                                        icon: Icons.add,
                                        label: 'Додати товар',
                                        hint: '(A)',
                                      ),
                                    ),
                                    SizedBox(height: AppSizes.paddingSM),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => setState(
                                              () => _showEditListModal = true,
                                            ),
                                            icon: const Icon(
                                              Icons.edit,
                                              size: AppSizes.iconSizeSmall,
                                            ),
                                            label: const Text('Редагувати'),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: AppSizes.paddingSM,
                                        ),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => setState(
                                              () => _showShareModal = true,
                                            ),
                                            icon: const Icon(
                                              Icons.share,
                                              size: AppSizes.iconSizeSmall,
                                            ),
                                            label: const Text(
                                              'Спільний доступ',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          finalList.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        if (finalList.color != null) ...[
                                          const SizedBox(width: 12),
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: ColorUtils.parseColor(
                                                finalList.color!,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          GradientButton.icon(
                                            onPressed: () {
                                              // Логування події відкриття форми створення айтема
                                              FirebaseAnalytics.instance.logEvent(
                                                name:
                                                    'create_item_dialog_opened',
                                                parameters: {
                                                  'list_id': widget.listId,
                                                },
                                              );
                                              setState(
                                                () => _showAddModal = true,
                                              );
                                            },
                                            icon: Icons.add,
                                            label: 'Додати товар',
                                            hint: '(A)',
                                          ),
                                          const SizedBox(
                                            width: AppSizes.paddingSM,
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: () => setState(
                                              () => _showEditListModal = true,
                                            ),
                                            icon: const Icon(
                                              Icons.edit,
                                              size: AppSizes.iconSizeSmall,
                                            ),
                                            label: const Text('Редагувати'),
                                          ),
                                          const SizedBox(
                                            width: AppSizes.paddingSM,
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: () => setState(
                                              () => _showShareModal = true,
                                            ),
                                            icon: const Icon(
                                              Icons.share,
                                              size: AppSizes.iconSizeSmall,
                                            ),
                                            label: const Text(
                                              'Спільний доступ',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                          SizedBox(height: responsive.spacing),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(
                                AppSizes.borderRadiusMedium,
                              ),
                              border: Border.all(
                                color: AppColorScheme.getBorderLight(context),
                                width: AppSizes.borderWidthMedium,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: responsive.padding,
                            child: responsive.isMobile
                                ? Column(
                                    children: [
                                      _StatItem(
                                        value: items.length.toString(),
                                        label: 'Всього товарів',
                                      ),
                                      SizedBox(height: responsive.spacing),
                                      _StatItem(
                                        value: purchased.toString(),
                                        label: 'Куплено товарів',
                                        color: AppColors.success,
                                      ),
                                      SizedBox(height: responsive.spacing),
                                      _StatItem(
                                        value:
                                            '${totalPrice.toStringAsFixed(2)} ₴',
                                        label: 'Загальна вартість',
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _StatItem(
                                        value: items.length.toString(),
                                        label: 'Всього товарів',
                                      ),
                                      _StatItem(
                                        value: purchased.toString(),
                                        label: 'Куплено товарів',
                                        color: AppColors.success,
                                      ),
                                      _StatItem(
                                        value:
                                            '${totalPrice.toStringAsFixed(2)} ₴',
                                        label: 'Загальна вартість',
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                          ),
                          SizedBox(height: responsive.spacing),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColorScheme.getBgPrimary(context),
                              borderRadius: BorderRadius.circular(
                                AppSizes.borderRadiusMedium,
                              ),
                              border: Border.all(
                                color: AppColorScheme.getBorderLight(context),
                                width: AppSizes.borderWidthMedium,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(
                              responsive.isMobile
                                  ? AppSizes.paddingMD
                                  : AppSizes.spacingLG,
                            ),
                            child: responsive.isMobile
                                ? Column(
                                    children: [
                                      SearchField(
                                        hintText: 'Знайти товар...',
                                        onChanged: (value) =>
                                            setState(() => _searchTerm = value),
                                        value: _searchTerm,
                                      ),
                                      SizedBox(height: responsive.spacing),
                                      SortDropdown(
                                        value: _sortBy,
                                        icon: Icons.swap_vert,
                                        options: const [
                                          SortOption(
                                            value: 'default',
                                            label:
                                                'Спочатку новіші (додавання)',
                                          ),
                                          SortOption(
                                            value: 'name-asc',
                                            label: 'За назвою (А-Я)',
                                          ),
                                          SortOption(
                                            value: 'name-desc',
                                            label: 'За назвою (Я-А)',
                                          ),
                                          SortOption(
                                            value: 'price-asc',
                                            label: 'За ціною (зростання)',
                                          ),
                                          SortOption(
                                            value: 'price-desc',
                                            label: 'За ціною (спадання)',
                                          ),
                                          SortOption(
                                            value: 'quantity-asc',
                                            label: 'За кількістю (зростання)',
                                          ),
                                          SortOption(
                                            value: 'quantity-desc',
                                            label: 'За кількістю (спадання)',
                                          ),
                                          SortOption(
                                            value: 'date-old',
                                            label:
                                                'Спочатку старіші (додавання)',
                                          ),
                                        ],
                                        onChanged: (value) =>
                                            setState(() => _sortBy = value),
                                      ),
                                      SizedBox(height: responsive.spacing),
                                      FilterButtons(
                                        selectedValue: _filterBy,
                                        icon: Icons.filter_list,
                                        options: const [
                                          FilterOption(
                                            value: 'all',
                                            label: 'Всі',
                                          ),
                                          FilterOption(
                                            value: 'pending',
                                            label: 'Не куплені',
                                          ),
                                          FilterOption(
                                            value: 'purchased',
                                            label: 'Куплені',
                                          ),
                                        ],
                                        onChanged: (value) =>
                                            setState(() => _filterBy = value),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: SearchField(
                                          hintText: 'Знайти товар...',
                                          onChanged: (value) => setState(
                                            () => _searchTerm = value,
                                          ),
                                          value: _searchTerm,
                                        ),
                                      ),
                                      SizedBox(width: responsive.spacing),
                                      SortDropdown(
                                        value: _sortBy,
                                        icon: Icons.swap_vert,
                                        options: const [
                                          SortOption(
                                            value: 'default',
                                            label:
                                                'Спочатку новіші (додавання)',
                                          ),
                                          SortOption(
                                            value: 'name-asc',
                                            label: 'За назвою (А-Я)',
                                          ),
                                          SortOption(
                                            value: 'name-desc',
                                            label: 'За назвою (Я-А)',
                                          ),
                                          SortOption(
                                            value: 'price-asc',
                                            label: 'За ціною (зростання)',
                                          ),
                                          SortOption(
                                            value: 'price-desc',
                                            label: 'За ціною (спадання)',
                                          ),
                                          SortOption(
                                            value: 'quantity-asc',
                                            label: 'За кількістю (зростання)',
                                          ),
                                          SortOption(
                                            value: 'quantity-desc',
                                            label: 'За кількістю (спадання)',
                                          ),
                                          SortOption(
                                            value: 'date-old',
                                            label:
                                                'Спочатку старіші (додавання)',
                                          ),
                                        ],
                                        onChanged: (value) =>
                                            setState(() => _sortBy = value),
                                      ),
                                      SizedBox(width: responsive.spacing),
                                      FilterButtons(
                                        selectedValue: _filterBy,
                                        icon: Icons.filter_list,
                                        options: const [
                                          FilterOption(
                                            value: 'all',
                                            label: 'Всі',
                                          ),
                                          FilterOption(
                                            value: 'pending',
                                            label: 'Не куплені',
                                          ),
                                          FilterOption(
                                            value: 'purchased',
                                            label: 'Куплені',
                                          ),
                                        ],
                                        onChanged: (value) =>
                                            setState(() => _filterBy = value),
                                      ),
                                    ],
                                  ),
                          ),
                          SizedBox(height: responsive.spacing),
                          Text(
                            _filterBy == 'all'
                                ? 'Всі товари (${items.length})'
                                : _filterBy == 'pending'
                                ? 'Не куплені (${items.where((i) => i.status == ItemStatus.pending).length})'
                                : 'Куплені (${items.where((i) => i.status == ItemStatus.purchased).length})',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          if (filteredItems.isEmpty)
                            EmptyState(
                              icon: Icons.shopping_bag_outlined,
                              title: _filterBy == 'all'
                                  ? 'Немає товарів у списку'
                                  : _filterBy == 'pending'
                                  ? 'Немає не куплених товарів'
                                  : 'Немає куплених товарів',
                              subtitle:
                                  _searchTerm.isNotEmpty || _filterBy != 'all'
                                  ? 'Спробуйте змінити фільтри'
                                  : 'Додайте перший товар',
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                final isPurchased =
                                    item.status == ItemStatus.purchased;
                                final category = item.categoryId != null
                                    ? store.categories.firstWhere(
                                        (c) => c.id == item.categoryId,
                                        orElse: () => store.categories
                                            .firstWhere((c) => c.id == 'other'),
                                      )
                                    : null;

                                Color parseCategoryColor(String colorClass) {
                                  if (colorClass.contains('green')) {
                                    return const Color(0xFF22C55E);
                                  }
                                  if (colorClass.contains('blue')) {
                                    return const Color(0xFF3B82F6);
                                  }
                                  if (colorClass.contains('gray')) {
                                    return const Color(0xFF6B7280);
                                  }
                                  return const Color(0xFF6B7280);
                                }

                                final isDark =
                                    Theme.of(context).brightness ==
                                    Brightness.dark;

                                return Container(
                                  margin: const EdgeInsets.only(
                                    bottom: AppSizes.paddingSM,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isPurchased
                                        ? AppColorScheme.getBgTertiary(context)
                                        : AppColorScheme.getBgPrimary(context),
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.cardBorderRadius,
                                    ),
                                    border: Border.all(
                                      color: AppColorScheme.getBorderLight(
                                        context,
                                      ),
                                      width: AppSizes.borderWidthThin,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(
                                    AppSizes.spacingLG,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          decoration:
                                                              isPurchased
                                                              ? TextDecoration
                                                                    .lineThrough
                                                              : null,
                                                          color: isPurchased
                                                              ? AppColorScheme.getTextTertiary(
                                                                  context,
                                                                )
                                                              : AppColorScheme.getTextPrimary(
                                                                  context,
                                                                ),
                                                        ),
                                                  ),
                                                ),
                                                if (category != null) ...[
                                                  const SizedBox(
                                                    width: AppSizes.paddingSM,
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: AppSizes
                                                              .paddingSM,
                                                          vertical: AppSizes
                                                              .paddingXS,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: parseCategoryColor(
                                                        category.color,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            AppSizes
                                                                .borderRadiusMedium,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      category.nameUk,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: AppSizes
                                                            .inputFontSize,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: AppSizes.paddingMD,
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                onTap: () {},
                                                child: TextButton(
                                                  onPressed: () async {
                                                    final store =
                                                        Provider.of<AppStore>(
                                                          context,
                                                          listen: false,
                                                        );

                                                    if (_cachedList == null ||
                                                        _cachedList!.id !=
                                                            widget.listId) {
                                                      final list = store.lists
                                                          .where(
                                                            (l) =>
                                                                l.id ==
                                                                widget.listId,
                                                          )
                                                          .firstOrNull;
                                                      if (list != null) {
                                                        _cachedList = list;
                                                      }
                                                    }

                                                    try {
                                                      final newStatus =
                                                          isPurchased
                                                          ? ItemStatus.pending
                                                          : ItemStatus
                                                                .purchased;
                                                      final updatedItem = item
                                                          .copyWith(
                                                            status: newStatus,
                                                            purchasedAt:
                                                                isPurchased
                                                                ? null
                                                                : DateTime.now(),
                                                          );

                                                      await store.updateItem(
                                                        updatedItem,
                                                      );

                                                      if (!mounted) return;

                                                      // Логування події зміни статусу айтема
                                                      if (newStatus ==
                                                          ItemStatus
                                                              .purchased) {
                                                        FirebaseAnalytics
                                                            .instance
                                                            .logEvent(
                                                              name:
                                                                  'item_purchased',
                                                              parameters: {
                                                                'item_id':
                                                                    item.id,
                                                                'item_name':
                                                                    item.name,
                                                                'list_id':
                                                                    item.listId,
                                                                'price':
                                                                    item.price ??
                                                                    0.0,
                                                              },
                                                            );
                                                      } else {
                                                        FirebaseAnalytics
                                                            .instance
                                                            .logEvent(
                                                              name:
                                                                  'item_unpurchased',
                                                              parameters: {
                                                                'item_id':
                                                                    item.id,
                                                                'item_name':
                                                                    item.name,
                                                                'list_id':
                                                                    item.listId,
                                                              },
                                                            );
                                                      }
                                                    } catch (e) {
                                                      if (!mounted) return;
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Помилка оновлення: $e',
                                                          ),
                                                          backgroundColor:
                                                              AppColors.error,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  style: TextButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: AppSizes
                                                              .paddingMD,
                                                          vertical: AppSizes
                                                              .paddingSM,
                                                        ),
                                                    backgroundColor: isPurchased
                                                        ? AppColors.successBg
                                                              .withValues(
                                                                alpha: isDark
                                                                    ? 0.2
                                                                    : 1.0,
                                                              )
                                                        : null,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            AppSizes
                                                                .borderRadiusSmall,
                                                          ),
                                                    ),
                                                    tapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        isPurchased
                                                            ? Icons.check_box
                                                            : Icons
                                                                  .check_box_outline_blank,
                                                        size: AppSizes
                                                            .iconSizeSmall,
                                                        color: isPurchased
                                                            ? AppColors.success
                                                            : AppColorScheme.getTextSecondary(
                                                                context,
                                                              ),
                                                      ),
                                                      const SizedBox(
                                                        width:
                                                            AppSizes.paddingXS,
                                                      ),
                                                      Text(
                                                        isPurchased
                                                            ? 'Куплено'
                                                            : 'Не куплено',
                                                        style: TextStyle(
                                                          fontSize: AppSizes
                                                              .inputFontSize,
                                                          color: isPurchased
                                                              ? AppColors
                                                                    .success
                                                              : AppColorScheme.getTextSecondary(
                                                                  context,
                                                                ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: AppSizes.paddingXS,
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  size: AppSizes.iconSizeSmall,
                                                  color:
                                                      AppColorScheme.getTextTertiary(
                                                        context,
                                                      ),
                                                ),
                                                onPressed: isPurchased
                                                    ? null
                                                    : () {
                                                        setState(
                                                          () => _editingItem =
                                                              item,
                                                        );
                                                      },
                                                style: IconButton.styleFrom(
                                                  backgroundColor:
                                                      AppColorScheme.getBgTertiary(
                                                        context,
                                                      ),
                                                  padding: const EdgeInsets.all(
                                                    AppSizes.paddingSM,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  size: AppSizes.iconSizeSmall,
                                                ),
                                                color: AppColors.error,
                                                onPressed: () {
                                                  setState(() {
                                                    _itemToDelete = item;
                                                    _showDeleteItemConfirm =
                                                        true;
                                                  });
                                                },
                                                style: IconButton.styleFrom(
                                                  backgroundColor: AppColors
                                                      .errorBg
                                                      .withValues(
                                                        alpha: isDark
                                                            ? 0.2
                                                            : 1.0,
                                                      ),
                                                  padding: const EdgeInsets.all(
                                                    AppSizes.paddingSM,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: AppSizes.paddingXS,
                                      ),
                                      Text(
                                        '${item.quantity} ${item.unit.label}${item.price != null ? ' • ${item.price!.toStringAsFixed(2)} ₴' : ''}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  AppColorScheme.getTextSecondary(
                                                    context,
                                                  ),
                                              fontSize: AppSizes.inputFontSize,
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          SizedBox(height: responsive.spacing),
                          Builder(
                            builder: (context) {
                              final quickAddController =
                                  TextEditingController();
                              final isDarkMode =
                                  Theme.of(context).brightness ==
                                  Brightness.dark;
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? AppColors.darkBorderMedium
                                        : AppColors.borderMedium,
                                    width: AppSizes.borderWidthMedium,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: quickAddController,
                                            onSubmitted: (value) async {
                                              if (value.trim().isNotEmpty) {
                                                await store.addItem(
                                                  listId: widget.listId,
                                                  name: value.trim(),
                                                  quantity: 1,
                                                  unit: Unit.pcs,
                                                );
                                                quickAddController.clear();
                                              }
                                            },
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Введіть назву товару для швидкого додавання...',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppSizes
                                                          .borderRadiusSmall,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: isDarkMode
                                                      ? AppColors
                                                            .darkBorderMedium
                                                      : AppColors.borderMedium,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: isDarkMode
                                                  ? AppColors.darkBgTertiary
                                                  : AppColors.bgPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (quickAddController.text
                                                .trim()
                                                .isNotEmpty) {
                                              await store.addItem(
                                                listId: widget.listId,
                                                name: quickAddController.text
                                                    .trim(),
                                                quantity: 1,
                                                unit: Unit.pcs,
                                              );
                                              quickAddController.clear();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.success,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Додати'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Швидко додайте товар з базовими налаштуваннями (1 шт.). Для детальних налаштувань використовуйте кнопку "Додати товар" вище.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: isDarkMode
                                                ? AppColors.darkTextTertiary
                                                : AppColors.textSecondary,
                                            fontSize: AppSizes.inputFontSize,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // Логування події відкриття форми створення айтема
                  FirebaseAnalytics.instance.logEvent(
                    name: 'create_item_dialog_opened',
                    parameters: {'list_id': widget.listId},
                  );
                  setState(() => _showAddModal = true);
                },
                child: const Icon(Icons.add),
              ),
            ),
            if (_showAddModal)
              AddItemModal(
                listId: widget.listId,
                onClose: () => setState(() => _showAddModal = false),
              ),
            if (_editingItem != null)
              EditItemModal(
                item: _editingItem!,
                onClose: () => setState(() => _editingItem = null),
              ),
            if (_showEditListModal)
              EditListModal(
                list: finalList,
                onClose: () => setState(() => _showEditListModal = false),
              ),
            if (_showShareModal)
              ShareListModal(
                listId: finalList.id,
                listName: finalList.name,
                onClose: () => setState(() => _showShareModal = false),
              ),
            if (_showDeleteItemConfirm && _itemToDelete != null)
              DeleteConfirmModal(
                title: 'Підтвердження видалення',
                message:
                    'Ви впевнені, що хочете видалити товар "${_itemToDelete!.name}"? Цю дію неможливо скасувати.',
                onConfirm: () async {
                  final itemId = _itemToDelete!.id;
                  final itemName = _itemToDelete!.name;
                  final listId = _itemToDelete!.listId;

                  await store.removeItem(itemId);

                  // Логування події видалення айтема
                  FirebaseAnalytics.instance.logEvent(
                    name: 'item_deleted',
                    parameters: {
                      'item_id': itemId,
                      'item_name': itemName,
                      'list_id': listId,
                    },
                  );

                  setState(() {
                    _showDeleteItemConfirm = false;
                    _itemToDelete = null;
                  });
                },
                onCancel: () {
                  setState(() {
                    _showDeleteItemConfirm = false;
                    _itemToDelete = null;
                  });
                },
              ),
          ],
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;

  const _StatItem({required this.value, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColorScheme.getTextSecondary(context),
          ),
        ),
      ],
    );
  }
}
