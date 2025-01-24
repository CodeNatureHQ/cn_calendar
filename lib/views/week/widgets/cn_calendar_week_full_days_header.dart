import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:flutter/material.dart';

class CnCalendarWeekFullDaysHeader extends StatelessWidget {
  const CnCalendarWeekFullDaysHeader({
    super.key,
    required this.calendarEntries,
  });

  final List<CnCalendarEntry> calendarEntries;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 1, child: SizedBox.shrink()),
        Expanded(
          flex: 7,
          child: Column(
            spacing: 2,
            children: placeFullDayEvents(),
          ),
        ),
      ],
    );
  }

  List<Widget> placeFullDayEvents() {
    return calendarEntries.map((entry) {
      // Check from the startOfDay to get the difference in days correct
      final start = entry.dateFrom.startOfDay;
      final end = entry.dateUntil.startOfDay;

      final entryStartDay = start.weekday - 1; // Starttag (Montag = 0)
      final entryLength = end.difference(start).inDays + 1;

      return LayoutBuilder(
        builder: (context, constraints) {
          final dayWidth = constraints.maxWidth / 7; // Breite eines Tages

          // Liste von Widgets für die `Row`
          List<Widget> rowChildren = [];

          // 1. Platzhalter für die Tage vor dem Event
          if (entryStartDay > 0) {
            rowChildren.add(SizedBox(width: entryStartDay * dayWidth));
          }

          // 2. Container für das Event selbst
          rowChildren.add(
            Container(
              height: 24,
              width: entryLength * dayWidth,
              decoration: BoxDecoration(color: entry.color, borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              child: Text(
                entry.title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );

          // 3. Platzhalter für die Tage nach dem Event (optional)
          final remainingDays = 6 - (entryStartDay + entryLength - 1);
          if (remainingDays > 0) {
            rowChildren.add(SizedBox(width: remainingDays * dayWidth));
          }

          // Rückgabe der `Row`
          return Row(
            children: rowChildren,
          );
        },
      );
    }).toList();
  }
}
