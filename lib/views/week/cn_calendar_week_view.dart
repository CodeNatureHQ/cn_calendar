import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:cn_calendar/views/week/widgets/cn_calendar_week_full_days_header.dart';
import 'package:cn_calendar/views/week/widgets/cn_calendar_week_grid.dart';
import 'package:cn_calendar/views/week/widgets/cn_calendar_week_week_days.dart';
import 'package:flutter/material.dart';

class CnCalendarWeekView extends StatelessWidget {
  const CnCalendarWeekView({
    super.key,
    required this.selectedWeek,
    this.calendarEntries = const [],
    this.onDateChanged,
    this.onEntryTapped,
    this.onDayTapped,
    this.onTimeTapped,
  });

  /// Should always be the first day of the week
  final DateTime selectedWeek;

  /// Entries to be shown in the month week
  final List<CnCalendarEntry> calendarEntries;

  /// Called whenever the PageView changes the week
  final Function(DateTime date)? onDateChanged;

  /// Called whenever an entry is tapped
  final Function(CnCalendarEntry entry)? onEntryTapped;

  /// Called whenever a day in the week days section is tapped
  final Function(DateTime date)? onDayTapped;

  /// Called whenever a time slot is tapped
  /// This is useful for creating new entries at a specific time
  final Function(DateTime time)? onTimeTapped;

  @override
  Widget build(BuildContext context) {
    final decoration = CnProvider.of(context).decoration;
    return Container(
      color: decoration.backgroundColor,
      child: Column(
        children: [
          CnCalendarWeekWeekDays(
            selectedWeek: selectedWeek,
            onDayTapped: onDayTapped,
            decoration: decoration,
            entries: calendarEntries,
          ),
          CnCalendarWeekFullDaysHeader(
            selectedWeek: selectedWeek,
            calendarEntries: calendarEntries.where((entry) => entry.isFullDay).toList(),
            onEntryTapped: onEntryTapped,
          ),
          if (calendarEntries.any((entry) => entry.isFullDay)) const Divider(),
          Expanded(
            child: CnCalendarWeekGrid(
              selectedWeek: selectedWeek,
              calendarEntries: calendarEntries.where((entry) => !entry.isFullDay).toList(),
              onEntryTapped: onEntryTapped,
              onTimeTapped: onTimeTapped,
            ),
          ),
        ],
      ),
    );
  }
}
