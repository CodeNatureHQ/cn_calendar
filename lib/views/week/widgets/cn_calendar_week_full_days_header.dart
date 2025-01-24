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
          child: Stack(
            children: [
              Column(
                spacing: 2,
                children: placeFullDayEvents(),
              ),
            ],
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

      // Starting day is Monday
      final entryStartDay = start.weekday - 1;
      final entryLength = end.difference(start).inDays + 1;

      return LayoutBuilder(
        builder: (context, constraints) {
          // Width of a day
          final dayWidth = constraints.maxWidth / 7;
          return Row(
            children: [
              SizedBox(width: entryStartDay * dayWidth),
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
            ],
          );
        },
      );
    }).toList();
  }
}
