import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:flutter/material.dart';

class CnCalendarWeekFullDaysHeader extends StatelessWidget {
  const CnCalendarWeekFullDaysHeader({
    super.key,
    required this.selectedWeek,
    required this.calendarEntries,
    required this.onEntryTapped,
  });

  final DateTime selectedWeek;
  final List<CnCalendarEntry> calendarEntries;
  final Function(CnCalendarEntry entry)? onEntryTapped;

  @override
  Widget build(BuildContext context) {
    final eventRows = _calculateEventRows();
    final rowCount = eventRows.isEmpty ? 0 : (eventRows.values.reduce((a, b) => a > b ? a : b) + 1);

    return Row(
      children: [
        Expanded(flex: 1, child: SizedBox.shrink()),
        Expanded(
          flex: 7,
          child: SizedBox(
            height: rowCount * 26.0, // 24px height + 2px spacing
            child: Stack(children: _buildEventWidgets(eventRows)),
          ),
        ),
      ],
    );
  }

  Map<CnCalendarEntry, int> _calculateEventRows() {
    final weekStart = selectedWeek.firstDayOfWeek.startOfDay;
    final weekEnd = weekStart.add(const Duration(days: 6)).startOfDay;

    // Filter and prepare events
    final visibleEvents = <Map<String, dynamic>>[];

    for (final entry in calendarEntries) {
      final eventStart = entry.dateFrom.startOfDay;
      final eventEnd = entry.dateUntil.startOfDay;

      // Clip to week
      final visibleStart = eventStart.isBefore(weekStart) ? weekStart : eventStart;
      final visibleEnd = eventEnd.isAfter(weekEnd) ? weekEnd : eventEnd;

      if (!visibleStart.isAfter(visibleEnd)) {
        final entryStartDay = visibleStart.difference(weekStart).inDays;
        final entryEndDay = visibleEnd.difference(weekStart).inDays;

        visibleEvents.add({'entry': entry, 'startDay': entryStartDay, 'endDay': entryEndDay});
      }
    }

    // Sort events by start day, then by duration (longer events first)
    visibleEvents.sort((a, b) {
      final startComparison = (a['startDay'] as int).compareTo(b['startDay'] as int);
      if (startComparison != 0) return startComparison;
      final aDuration = (a['endDay'] as int) - (a['startDay'] as int);
      final bDuration = (b['endDay'] as int) - (b['startDay'] as int);
      return bDuration.compareTo(aDuration); // Longer events first
    });

    // Track occupied days for each row
    final rows = <List<bool>>[];
    final eventToRow = <CnCalendarEntry, int>{};

    for (final eventData in visibleEvents) {
      final entry = eventData['entry'] as CnCalendarEntry;
      final startDay = eventData['startDay'] as int;
      final endDay = eventData['endDay'] as int;

      // Find the first row where this event fits
      int targetRow = -1;
      for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
        bool canFit = true;
        for (int day = startDay; day <= endDay; day++) {
          if (day < rows[rowIndex].length && rows[rowIndex][day]) {
            canFit = false;
            break;
          }
        }
        if (canFit) {
          targetRow = rowIndex;
          break;
        }
      }

      // If no existing row can fit the event, create a new row
      if (targetRow == -1) {
        targetRow = rows.length;
        rows.add(List.filled(7, false));
      }

      // Mark the days as occupied in the target row
      for (int day = startDay; day <= endDay; day++) {
        if (day < 7) {
          if (day >= rows[targetRow].length) {
            rows[targetRow].addAll(List.filled(day - rows[targetRow].length + 1, false));
          }
          rows[targetRow][day] = true;
        }
      }

      eventToRow[entry] = targetRow;
    }

    return eventToRow;
  }

  List<Widget> _buildEventWidgets(Map<CnCalendarEntry, int> eventRows) {
    final weekStart = selectedWeek.firstDayOfWeek.startOfDay;
    final weekEnd = weekStart.add(const Duration(days: 6)).startOfDay;

    return [
      LayoutBuilder(
        builder: (context, constraints) {
          final dayWidth = constraints.maxWidth / 7;
          final eventWidgets = <Widget>[];

          for (final entry in calendarEntries) {
            final row = eventRows[entry];
            if (row == null) continue;

            final eventStart = entry.dateFrom.startOfDay;
            final eventEnd = entry.dateUntil.startOfDay;

            // Clip to week
            final visibleStart = eventStart.isBefore(weekStart) ? weekStart : eventStart;
            final visibleEnd = eventEnd.isAfter(weekEnd) ? weekEnd : eventEnd;

            if (visibleStart.isAfter(visibleEnd)) continue;

            final entryStartDay = visibleStart.difference(weekStart).inDays;
            final entryLength = visibleEnd.difference(visibleStart).inDays + 1;

            eventWidgets.add(
              Positioned(
                top: row * 26.0, // 24px height + 2px spacing
                left: entryStartDay * dayWidth,
                child: GestureDetector(
                  onTap: () => onEntryTapped?.call(entry),
                  child: Container(
                    height: 24,
                    width: entryLength * dayWidth,
                    decoration: BoxDecoration(color: entry.color, borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                    child:
                        entry.content ??
                        Text(
                          entry.title,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                  ),
                ),
              ),
            );
          }

          return Stack(children: eventWidgets);
        },
      ),
    ];
  }
}
