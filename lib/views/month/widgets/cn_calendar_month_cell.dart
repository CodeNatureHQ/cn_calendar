import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/models/cn_decoration.dart';
import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:cn_calendar/views/month/widgets/cn_calendar_month_entry_card.dart';
import 'package:cn_calendar/views/month/widgets/cn_calendar_month_event_layout.dart';
import 'package:flutter/material.dart';

class CnCalendarMonthCell extends StatelessWidget {
  const CnCalendarMonthCell({
    super.key,
    required this.date,
    required this.selectedMonth,
    this.positionedEvents = const [],
    this.timedEntries = const [],
    this.overflowCount = 0,
    this.hideTopBorder = false,
    this.onDayTapped,
  });

  final DateTime date;
  final DateTime selectedMonth;
  final List<PositionedMonthEvent> positionedEvents;
  final List<CnCalendarEntry> timedEntries;
  final int overflowCount;
  final bool hideTopBorder;
  final Function(DateTime)? onDayTapped;

  /// Build the event rows with proper positioning
  Widget _buildEventRows() {
    if (positionedEvents.isEmpty && overflowCount == 0 && timedEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    const double eventHeight = 18.0;
    const double timedEventHeight = 14.0;
    const double eventSpacing = 2.0;
    const int maxVisibleItems = 3; // Maximum 3 items total (full-day + timed events)

    return LayoutBuilder(
      builder: (context, constraints) {
        // Group full-day events by row
        final eventsByRow = <int, PositionedMonthEvent>{};
        for (final event in positionedEvents) {
          eventsByRow[event.row] = event;
        }

        final children = <Widget>[];
        int itemsShown = 0;

        // Find the maximum row number we have
        final maxRow = eventsByRow.keys.isEmpty ? -1 : eventsByRow.keys.reduce((a, b) => a > b ? a : b);

        // Build full-day event rows
        for (int row = 0; row <= maxRow && itemsShown < maxVisibleItems; row++) {
          final positioned = eventsByRow[row];

          if (positioned != null) {
            children.add(
              Padding(
                padding: EdgeInsets.only(bottom: eventSpacing),
                child: SizedBox(
                  height: eventHeight,
                  child: CnCalendarMonthEntryCard(entry: positioned.entry, date: date, selectedMonth: selectedMonth),
                ),
              ),
            );
            itemsShown++;
          } else {
            // Empty row - add spacer to maintain layout
            children.add(SizedBox(height: eventHeight + eventSpacing));
            itemsShown++;
          }
        }

        // Add timed events if we have space
        final remainingSlots = maxVisibleItems - itemsShown;
        if (remainingSlots > 0 && timedEntries.isNotEmpty) {
          final visibleTimedEvents = timedEntries.take(remainingSlots).toList();

          for (final entry in visibleTimedEvents) {
            children.add(
              Padding(
                padding: EdgeInsets.only(bottom: eventSpacing, left: 2, right: 2),
                child: SizedBox(height: timedEventHeight, child: _buildTimedEventCard(entry)),
              ),
            );
            itemsShown++;
          }
        }

        // Calculate total overflow
        final hiddenFullDayEvents = overflowCount + (maxRow >= maxVisibleItems ? (maxRow - maxVisibleItems + 1) : 0);
        final hiddenTimedEvents = timedEntries.length - (itemsShown - (maxRow + 1).clamp(0, maxVisibleItems));
        final totalOverflow = hiddenFullDayEvents + hiddenTimedEvents;

        // Add "+X more" indicator for all hidden events
        if (totalOverflow > 0) {
          children.add(
            GestureDetector(
              onTap: () => onDayTapped?.call(date),
              child: Container(
                height: timedEventHeight,
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                child: Text(
                  '+$totalOverflow more',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
                ),
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      },
    );
  }

  /// Build a single timed event card
  Widget _buildTimedEventCard(CnCalendarEntry entry) {
    final isCurrentMonth = date.month == selectedMonth.month;
    final color = isCurrentMonth ? entry.color : entry.color.withValues(alpha: 0.7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border(left: BorderSide(color: color, width: 2)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          Text(
            '${entry.dateFrom.hour.toString().padLeft(2, '0')}:${entry.dateFrom.minute.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 8, color: Colors.grey.shade300, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              entry.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                color: isCurrentMonth ? Colors.white : Colors.grey.shade400,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
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
            height: 22,
            padding: const EdgeInsets.all(2),
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
                    fontSize: 11,
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
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: _buildEventRows()),
          ),
        ],
      ),
    );
  }
}
