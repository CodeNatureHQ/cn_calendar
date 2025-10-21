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
    this.eventPositions = const {},
  });

  final DateTime date;
  final DateTime selectedMonth;
  final List<CnCalendarEntry> calendarEntries;
  final bool hideTopBorder;
  final Function(DateTime)? onDayTapped;
  final Map<String, int> eventPositions;

  /// Get the content for entries with proper overflow handling
  Widget getEntriesContent() {
    if (calendarEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort entries using pre-assigned positions for multi-day events
    final sortedEntries = [...calendarEntries];
    sortedEntries.sort((a, b) {
      final aIsMultiDay = a.dateUntil.difference(a.dateFrom).inDays > 0;
      final bIsMultiDay = b.dateUntil.difference(b.dateFrom).inDays > 0;

      // Both are multi-day: use pre-assigned positions
      if (aIsMultiDay && bIsMultiDay) {
        final aPosition = eventPositions[a.id] ?? 999;
        final bPosition = eventPositions[b.id] ?? 999;
        return aPosition.compareTo(bPosition);
      }

      // One multi-day, one single-day: multi-day comes first
      if (aIsMultiDay && !bIsMultiDay) return -1;
      if (!aIsMultiDay && bIsMultiDay) return 1;

      // Both single-day: sort by duration (longest first), then by start time
      final durationComparison = b.dateUntil
          .difference(b.dateFrom)
          .inDays
          .compareTo(a.dateUntil.difference(a.dateFrom).inDays);
      if (durationComparison != 0) return durationComparison;

      return a.dateFrom.compareTo(b.dateFrom);
    });

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
              // Calculate horizontal margin based on entry duration and position
              final entryDuration = entry.dateUntil.difference(entry.dateFrom).inDays + 1;
              final isMultiDay = entryDuration > 1;

              double leftMargin = 0.0;
              double rightMargin = 0.0;

              if (isMultiDay) {
                // For multi-day events, add small margins only at start and end
                final effectiveEndDate = entry.dateUntil.effectiveEndDate;
                final isFirstDay = date.isSameDate(entry.dateFrom);
                final isLastDay = date.isSameDate(effectiveEndDate);

                if (isFirstDay) {
                  leftMargin = 1.0; // Small breathing room at start
                }
                if (isLastDay) {
                  rightMargin = 1.0; // Small breathing room at end
                }
              } else {
                // Single day events keep normal margins
                leftMargin = 2.0;
                rightMargin = 2.0;
              }

              return Container(
                margin: EdgeInsets.only(bottom: entrySpacing, left: leftMargin, right: rightMargin),
                child: GestureDetector(
                  onTap: () => onDayTapped?.call(date),
                  child: SizedBox(
                    height: entryHeight,
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
                  margin: const EdgeInsets.only(bottom: entrySpacing, left: 2.0, right: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.5), width: 0.5),
                  ),
                  child: Center(
                    child: Text(
                      '+$remainingCount weitere',
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
            child: Container(padding: const EdgeInsets.only(top: 2, bottom: 2), child: getEntriesContent()),
          ),
        ],
      ),
    );
  }
}
