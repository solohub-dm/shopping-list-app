import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopping_list_app/utils/list_stats_calculator.dart';
import 'package:shopping_list_app/utils/color_utils.dart';

class CalendarView extends StatelessWidget {
  final List<ListWithStats> lists;
  final DateTime currentDate;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String> onListTap;
  final ValueChanged<DateTime> onCreateList;

  const CalendarView({
    super.key,
    required this.lists,
    required this.currentDate,
    required this.onDateChanged,
    required this.onListTap,
    required this.onCreateList,
  });

  @override
  Widget build(BuildContext context) {
    final groupedByDate = <String, List<ListWithStats>>{};
    for (final listData in lists) {
      final dateToUse = listData.list.dueDate ?? listData.list.createdAt;
      final dateKey = DateFormat('yyyy-MM-dd').format(dateToUse);
      groupedByDate.putIfAbsent(dateKey, () => []).add(listData);
    }

    final calendarData = _generateCalendarData(currentDate, groupedByDate);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.grey[200]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _CalendarHeader(
            currentDate: currentDate,
            onPreviousMonth: () {
              onDateChanged(DateTime(
                currentDate.year,
                currentDate.month - 1,
              ));
            },
            onNextMonth: () {
              onDateChanged(DateTime(
                currentDate.year,
                currentDate.month + 1,
              ));
            },
            onToday: () {
              onDateChanged(DateTime.now());
            },
            onMonthChanged: (month) {
              onDateChanged(DateTime(currentDate.year, month + 1));
            },
            onYearChanged: (year) {
              onDateChanged(DateTime(year, currentDate.month));
            },
          ),
          const SizedBox(height: 24),
          _CalendarGrid(
            calendarData: calendarData,
            currentDate: currentDate,
            onListTap: onListTap,
            onCreateList: onCreateList,
          ),
        ],
      ),
    );
  }

  _CalendarData _generateCalendarData(
    DateTime currentDate,
    Map<String, List<ListWithStats>> groupedByDate,
  ) {
    final now = DateTime.now();
    final firstDay = DateTime(currentDate.year, currentDate.month, 1);
    final lastDay = DateTime(currentDate.year, currentDate.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startDayOfWeek = firstDay.weekday - 1;

    final days = <_CalendarDay>[];

    for (int i = 0; i < startDayOfWeek; i++) {
      days.add(_CalendarDay(date: null, lists: []));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final dayDate = DateTime(currentDate.year, currentDate.month, day);
      final dateStr = DateFormat('yyyy-MM-dd').format(dayDate);
      final dayLists = groupedByDate[dateStr] ?? [];
      final isToday = dayDate.year == now.year &&
          dayDate.month == now.month &&
          dayDate.day == now.day;
      final isPast = dayDate.isBefore(now) && !isToday;

      days.add(_CalendarDay(
        date: day,
        lists: dayLists,
        isToday: isToday,
        isPast: isPast,
      ));
    }

    return _CalendarData(
      days: days,
      monthName: DateFormat('MMMM', 'uk_UA').format(currentDate),
      year: currentDate.year,
    );
  }
}

class _CalendarData {
  final List<_CalendarDay> days;
  final String monthName;
  final int year;

  _CalendarData({
    required this.days,
    required this.monthName,
    required this.year,
  });
}

class _CalendarDay {
  final int? date;
  final List<ListWithStats> lists;
  final bool isToday;
  final bool isPast;

  _CalendarDay({
    required this.date,
    required this.lists,
    this.isToday = false,
    this.isPast = false,
  });
}

class _CalendarHeader extends StatelessWidget {
  final DateTime currentDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;

  const _CalendarHeader({
    required this.currentDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToday,
    required this.onMonthChanged,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthName = DateFormat('MMMM', 'uk_UA').format(currentDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E3A8A).withValues(alpha: 0.2)
                    : const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_today,
                  size: 20, color: Color(0xFF2563EB)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  currentDate.year.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: onPreviousMonth,
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Попередній місяць',
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<int>(
                value: currentDate.month - 1,
                onChanged: (value) => onMonthChanged(value!),
                items: List.generate(12, (i) {
                  final monthDate = DateTime(2000, i + 1);
                  final monthName = DateFormat('MMMM', 'uk_UA').format(monthDate);
                  return DropdownMenuItem(
                    value: i,
                    child: Text(monthName),
                  );
                }),
                underline: const SizedBox(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<int>(
                value: currentDate.year,
                onChanged: (value) => onYearChanged(value!),
                items: List.generate(10, (i) {
                  final year = DateTime.now().year - 5 + i;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                underline: const SizedBox(),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onToday,
              child: const Text('Сьогодні'),
            ),
            IconButton(
              onPressed: onNextMonth,
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Наступний місяць',
            ),
          ],
        ),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final _CalendarData calendarData;
  final DateTime currentDate;
  final ValueChanged<String> onListTap;
  final ValueChanged<DateTime> onCreateList;

  const _CalendarGrid({
    required this.calendarData,
    required this.currentDate,
    required this.onListTap,
    required this.onCreateList,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд']
              .map((day) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                      ),
                    ),
                  ))
              .toList(          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
          ),
          itemCount: calendarData.days.length,
          itemBuilder: (context, index) {
            final day = calendarData.days[index];
            final now = DateTime.now();
            final hasOverdue = day.lists.any((listData) {
              final list = listData.list;
              final stats = listData.stats;
              return !stats.isCompleted &&
                  list.dueDate != null &&
                  list.dueDate!.isBefore(now);
            });
            final hasCompleted =
                day.lists.any((listData) => listData.stats.isCompleted);

            return _CalendarDayCell(
              day: day,
              hasOverdue: hasOverdue,
              hasCompleted: hasCompleted,
              currentDate: currentDate,
              onListTap: onListTap,
              onCreateList: onCreateList,
            );
          },
        ),
      ],
    );
  }
}

class _CalendarDayCell extends StatefulWidget {
  final _CalendarDay day;
  final bool hasOverdue;
  final bool hasCompleted;
  final DateTime currentDate;
  final ValueChanged<String> onListTap;
  final ValueChanged<DateTime> onCreateList;

  const _CalendarDayCell({
    required this.day,
    required this.hasOverdue,
    required this.hasCompleted,
    required this.currentDate,
    required this.onListTap,
    required this.onCreateList,
  });

  @override
  State<_CalendarDayCell> createState() => _CalendarDayCellState();
}

class _CalendarDayCellState extends State<_CalendarDayCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final day = widget.day;

    if (day.date == null) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[50],
          border: Border.all(
            color: isDark ? Colors.grey[600]! : Colors.grey[200]!,
          ),
        ),
      );
    }

    final dayDate = DateTime(
      widget.currentDate.year,
      widget.currentDate.month,
      day.date!,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: day.isToday
              ? (isDark
                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.2)
                  : const Color(0xFFDBEAFE))
              : day.isPast
                  ? (isDark ? Colors.grey[900] : Colors.grey[100])
                  : (isDark ? const Color(0xFF1F2937) : Colors.white),
          border: Border.all(
            color: day.isToday
                ? const Color(0xFF2563EB)
                : widget.hasOverdue
                    ? (isDark ? Colors.red[700]! : Colors.red[300]!)
                    : (isDark ? Colors.grey[600]! : Colors.grey[200]!),
            width: day.isToday ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day.date.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: day.isToday
                            ? const Color(0xFF2563EB)
                            : day.isPast
                                ? (isDark ? Colors.grey[600] : Colors.grey[400])
                                : (isDark ? Colors.white : Colors.grey[900]),
                      ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.hasOverdue)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (widget.hasOverdue && widget.hasCompleted)
                      const SizedBox(width: 4),
                    if (widget.hasCompleted)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (_isHovered) ...[
                      const SizedBox(width: 4),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => widget.onCreateList(dayDate),
                          borderRadius: BorderRadius.circular(4),
                          child: const Icon(Icons.add, size: 18),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: day.lists.length > 3 ? 3 : day.lists.length,
                itemBuilder: (context, index) {
                  final listData = day.lists[index];
                  final list = listData.list;
                  final stats = listData.stats;
                  final isOverdue = !stats.isCompleted &&
                      list.dueDate != null &&
                      list.dueDate!.isBefore(DateTime.now());

                  return GestureDetector(
                    onTap: () => widget.onListTap(list.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? (isDark
                                ? Colors.red[900]!.withValues(alpha: 0.2)
                                : Colors.red[100])
                            : stats.isCompleted
                                ? (isDark
                                    ? Colors.green[900]!.withValues(alpha: 0.2)
                                    : Colors.green[100])
                                : (isDark ? Colors.grey[800] : Colors.grey[50]),
                        borderRadius: BorderRadius.circular(4),
                        border: isOverdue
                            ? Border(
                                left: BorderSide(
                                  color: Colors.red[500]!,
                                  width: 2,
                                ),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          if (list.color != null)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: ColorUtils.parseColor(list.color!),
                                shape: BoxShape.circle,
                              ),
                            ),
                          if (list.color != null) const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              list.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (day.lists.length > 3)
              Text(
                '+${day.lists.length - 3}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

