import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/models/cn_decoration.dart';
import 'package:coo_extensions/extensions/date_time.extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CnCalendarWeekWeekDays extends StatelessWidget {
  const CnCalendarWeekWeekDays({
    super.key,
    required this.selectedWeek,
    this.onDayTapped,
    required this.decoration,
    this.entries = const [],
  });

  final DateTime selectedWeek;
  final Function(DateTime date)? onDayTapped;
  final CnDecoration decoration;
  final List<CnCalendarEntry> entries;

  @override
  Widget build(BuildContext context) {
    // Define a list of weekays starting from Monday
    final weekdays = DateFormat().dateSymbols.STANDALONESHORTWEEKDAYS;

    return ColoredBox(
      color: decoration.headerBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            8, // 8 is used to create a whitespace for the timeline
            (index) {
              final date = selectedWeek.firstDayOfWeek.add(Duration(days: index - 1));
              final weekdayIndex = (index) % 7; // Ensures we start from Monday
              // The first column is the timeline
              if (index == 0) return Expanded(child: SizedBox.shrink());
              bool isToday = date.isSameDate(DateTime.now());

              // Check which entries are for the current date
              final entriesForDate = entries.where(
                (entry) => date.isBetween(entry.dateFrom.startOfDay, entry.dateUntil.endOfDay),
              );

              return Expanded(
                child: GestureDetector(
                  onTap: () => onDayTapped?.call(date),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isToday ? decoration.weekDaysHeaderSelectedBackgroundColor : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            weekdays[weekdayIndex],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  isToday
                                      ? decoration.weekDaysHeaderSelectedForegroundColor
                                      : decoration.weekDaysHeaderForegroundColor,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            date.day.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color:
                                  isToday
                                      ? decoration.weekDaysHeaderSelectedForegroundColor
                                      : decoration.weekDaysHeaderForegroundColor,
                            ),
                          ),
                          if (entriesForDate.isEmpty) SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var e in entriesForDate.take(3))
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: isToday ? decoration.entryDotColorActiveDay : decoration.entryDotColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
