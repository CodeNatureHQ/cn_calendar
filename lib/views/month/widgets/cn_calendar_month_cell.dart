import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/models/cn_decoration.dart';
import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:cn_calendar/views/month/widgets/cn_calendar_month_entry_card.dart';
import 'package:flutter/material.dart';

class CnCalendarMonthCell extends StatelessWidget {
  const CnCalendarMonthCell({
    super.key,
    required this.date,
    required this.selectedMonth,
    this.calendarEntries = const [],
    this.hideTopBorder = false,
    this.onDayTapped,
  });

  final DateTime date;
  final DateTime selectedMonth;
  final List<CnCalendarEntry> calendarEntries;
  final bool hideTopBorder;
  final Function(DateTime)? onDayTapped;

  /// Get the content for entries with proper overflow handling
  Widget getEntriesContent() {
    if (calendarEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort entries by duration (longest first) for better visual hierarchy
    final sortedEntries = [...calendarEntries];
    sortedEntries.sort(
      (a, b) => b.dateUntil.difference(b.dateFrom).inDays.compareTo(a.dateUntil.difference(a.dateFrom).inDays),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const double entryHeight = 16.0;
        const double entrySpacing = 2.0;

        // Calculate how many entries can fit
        final availableHeight = constraints.maxHeight;
        final maxVisibleEntries = ((availableHeight - entrySpacing) / (entryHeight + entrySpacing)).floor() - 1;

        if (maxVisibleEntries <= 0) {
          return const SizedBox.shrink();
        }

        // Take only the entries that fit
        final visibleEntries = sortedEntries.take(maxVisibleEntries).toList();
        final remainingCount = sortedEntries.length - visibleEntries.length;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show visible entries
            ...visibleEntries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: entrySpacing),
                child: GestureDetector(
                  onTap: () => onDayTapped?.call(date),
                  child: Container(
                    height: entryHeight,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: CnCalendarMonthEntryCard(entry: entry, date: date, selectedMonth: selectedMonth),
                  ),
                ),
              );
            }),

            // Show "+X more" if there are remaining entries
            if (remainingCount > 0)
              GestureDetector(
                onTap: () => onDayTapped?.call(date),
                child: Container(
                  height: entryHeight,
                  margin: const EdgeInsets.only(bottom: entrySpacing),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.5), width: 0.5),
                  ),
                  child: Center(
                    child: Text(
                      '+$remainingCount more',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black54),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// The decoration of the day cell
  BoxDecoration getBoxDecoration(CnDecoration decoration) {
    Color cellColor = decoration.monthViewDayBackgroundColor;
    Color borderColor = decoration.monthViewSelectedMonthBorderColor;

    if (date.isSameDate(DateTime.now())) {
      cellColor = decoration.monthViewDaySelectedBackgroundColor;
    } else if (date.month == selectedMonth.month) {
      cellColor = decoration.monthViewDayBackgroundColor;
      borderColor = decoration.monthViewSelectedMonthBorderColor;
    } else {
      cellColor = decoration.monthViewNotSelectedMonthBackgroundColor;
      borderColor = decoration.monthViewNotSelectedMonthBorderColor;
    }

    return BoxDecoration(
      color: cellColor,
      border: Border(
        top: BorderSide(color: hideTopBorder ? Colors.transparent : borderColor, width: 0.2),
        left: BorderSide(color: borderColor, width: 0.2),
        right: BorderSide(color: borderColor, width: 0.2),
        bottom: BorderSide(color: borderColor, width: 0.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final decoration = CnProvider.of(context).decoration;
    return Container(
      decoration: getBoxDecoration(decoration),
      child: Column(
        children: [
          // Day number header
          Container(
            height: 28,
            padding: const EdgeInsets.all(4),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: date.isSameDate(DateTime.now()) ? Colors.black : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  date.day.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: date.isSameDate(DateTime.now())
                        ? Colors.white
                        : date.month == selectedMonth.month
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          // Entries section
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: getEntriesContent(),
            ),
          ),
        ],
      ),
    );
  }
}
