import 'package:cn_calendar/extensions/date.extension.dart';
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
    this.overflowCount = 0,
    this.hideTopBorder = false,
    this.onDayTapped,
  });

  final DateTime date;
  final DateTime selectedMonth;
  final List<PositionedMonthEvent> positionedEvents;
  final int overflowCount;
  final bool hideTopBorder;
  final Function(DateTime)? onDayTapped;

  /// Build the event rows with proper positioning
  Widget _buildEventRows() {
    if (positionedEvents.isEmpty && overflowCount == 0) {
      return const SizedBox.shrink();
    }

    const double eventHeight = 18.0;
    const double eventSpacing = 2.0;
    const int maxVisibleRows = 3;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Group events by row
        final eventsByRow = <int, PositionedMonthEvent>{};
        for (final event in positionedEvents) {
          if (event.row < maxVisibleRows) {
            eventsByRow[event.row] = event;
          }
        }

        // Build rows
        final children = <Widget>[];

        // Find the maximum row number we have
        final maxRow = eventsByRow.keys.isEmpty ? 0 : eventsByRow.keys.reduce((a, b) => a > b ? a : b);

        // Build each row
        for (int row = 0; row <= maxRow && row < maxVisibleRows; row++) {
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
          } else {
            // Empty row - add spacer to maintain layout
            children.add(SizedBox(height: eventHeight + eventSpacing));
          }
        }

        // Add "+X more" indicator if there are overflow events
        if (overflowCount > 0) {
          children.add(
            GestureDetector(
              onTap: () => onDayTapped?.call(date),
              child: Container(
                height: eventHeight,
                margin: EdgeInsets.only(bottom: eventSpacing),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 0.5),
                ),
                child: Center(
                  child: Text(
                    '+$overflowCount more',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                  ),
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
