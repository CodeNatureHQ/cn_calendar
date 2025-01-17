import 'package:cn_calendar/cn_calendar.dart';
import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/models/cn_decoration.dart';
import 'package:flutter/material.dart';

class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CnCalendar(
          selectedDate: DateTime.now().startOfDay,
          onDateChanged: (date, view) {},
          decoration: CnDecoration(
            backgroundColor: Color(0xFFEDEDE9),
            headerBackgroundColor: Color(0xFF119589),
            headerForegroundColor: Color(0xFFEDEDE9),
            timelineLinesColor: Color(0xFFE1E2E3),
            timelineTextColor: Color(0xFF119589),
            headerSelectViewIconColor: Color(0xFFEDEDE9),
            weekDaysHeaderForegroundColor: Color(0xFFEDEDE9),
            weekDaysHeaderSelectedBackgroundColor: Color(0xFFEDEDE9),
            weekDaysHeaderSelectedForegroundColor: Color(0xFF119589),
            monthViewDayBackgroundColor: Color(0xFFEDEDE9),
            monthViewDaySelectedBackgroundColor: Color(0xFFEDEDE9),
            monthViewNotSelectedMonthBackgroundColor: Color(0xFFE1E2E3),
          ),
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
      ),
    );
  }
}
