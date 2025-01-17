import 'package:cn_calendar/cn_calendar.dart';
import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:flutter/material.dart';

class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: CnCalendar(
        selectedDate: DateTime.now().startOfDay,
        onDateChanged: (date, view) {},
        calendarEntries: [
          CnCalendarEntry(
            id: '0',
            title: 'Test',
            dateFrom: DateTime.now().startOfDay.add(Duration(hours: 3)),
            dateUntil: DateTime.now().startOfDay.add(Duration(hours: 7)),
            isFullDay: false,
          ),
          CnCalendarEntry(
            id: '0',
            title: 'Test',
            dateFrom: DateTime.now().startOfDay.add(Duration(hours: 4)),
            dateUntil: DateTime.now().startOfDay.add(Duration(hours: 7)),
            isFullDay: false,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
