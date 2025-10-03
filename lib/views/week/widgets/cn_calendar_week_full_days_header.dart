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
    return Row(
      children: [
        Expanded(flex: 1, child: SizedBox.shrink()),
        Expanded(
          flex: 7,
          child: Stack(children: [Column(spacing: 2, children: placeFullDayEvents())]),
        ),
      ],
    );
  }

  List<Widget> placeFullDayEvents() {
    final weekStart = selectedWeek.firstDayOfWeek.startOfDay;
    final weekEnd = weekStart.add(const Duration(days: 6)).startOfDay;

    return calendarEntries.map((entry) {
      final eventStart = entry.dateFrom.startOfDay;
      final eventEnd = entry.dateUntil.startOfDay;

      // Clip to week
      final visibleStart = eventStart.isBefore(weekStart) ? weekStart : eventStart;
      final visibleEnd = eventEnd.isAfter(weekEnd) ? weekEnd : eventEnd;

      if (visibleStart.isAfter(visibleEnd)) {
        // Not visible in this week
        return const SizedBox.shrink();
      }

      final entryStartDay = visibleStart.difference(weekStart).inDays;
      final entryLength = visibleEnd.difference(visibleStart).inDays + 1;

      return LayoutBuilder(
        builder: (context, constraints) {
          final dayWidth = constraints.maxWidth / 7;
          return Row(
            children: [
              SizedBox(width: entryStartDay * dayWidth),
              GestureDetector(
                onTap: () => onEntryTapped?.call(entry),
                child: Container(
                  height: 24,
                  width: entryLength * dayWidth,
                  decoration: BoxDecoration(color: entry.color, borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  child: entry.content ?? Text(entry.title, style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          );
        },
      );
    }).toList();
  }
}
