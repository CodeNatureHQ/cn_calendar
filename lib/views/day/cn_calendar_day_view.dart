import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:cn_calendar/views/day/widgets/cn_calendar_day_grid.dart';
import 'package:flutter/material.dart';

class CnCalendarDayView extends StatelessWidget {
  const CnCalendarDayView({
    super.key,
    required this.selectedDay,
    this.calendarEntries = const [],
    this.onDateChanged,
    this.onEntryTapped,
    this.onTimeTapped,
  });

  /// Should always be the first day of the week
  final DateTime selectedDay;

  /// Entries to be shown in the month week
  final List<CnCalendarEntry> calendarEntries;

  /// Called whenever the PageView changes the week
  final Function(DateTime date)? onDateChanged;

  /// Called whenever an entry is tapped
  final Function(CnCalendarEntry entry)? onEntryTapped;

  /// Called whenever a time slot is tapped
  /// This is useful for creating new entries at a specific time
  final Function(DateTime time)? onTimeTapped;

  @override
  Widget build(BuildContext context) {
    final decoration = CnProvider.of(context).decoration;
    return Container(
      color: decoration.backgroundColor,
      child: CnCalendarDayGrid(
        selectedDay: selectedDay,
        calendarEntries: calendarEntries,
        onEntryTapped: onEntryTapped,
        onTimeTapped: onTimeTapped,
        hourHeight: CnProvider.of(context).decoration.dayViewHourHeight,
      ),
    );
  }
}
