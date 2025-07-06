import 'package:cn_calendar/cn_calendar.dart';
import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/models/cn_calendar_view.dart';
import 'package:cn_calendar/models/cn_decoration.dart';
import 'package:flutter/material.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  // The calendar won't work properly if the current date isn't given inside the selectedDate property
  // and updated
  DateTime selectedDate = DateTime.now().startOfDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CnCalendar(
          onTimeTapped: (time) {
            print('Time tapped: $time');
          },
          onEntryTapped: (entry) => print('Entry tapped: ${entry.title}'),
          selectedDate: selectedDate,
          onDateChanged: (date, view) {
            selectedDate = date;
            setState(() {});
          },
          onHeaderTap: () {
            selectedDate = DateTime.now().startOfDay;
            setState(() {});
          },
          initialView: CnCalendarView.day,
          decoration: CnDecoration(
            dayViewHourHeight: 90,
            weekViewHourHeight: 60,
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
              title: 'Month bug',
              dateFrom: DateTime.now().endOfDay.subtract(Duration(days: 1)),
              dateUntil: DateTime.now().endOfDay.add(Duration(days: 2)),
              isFullDay: true,
              color: Colors.pink,
            ),
            CnCalendarEntry(
              id: '0',
              title: 'Test',
              dateFrom: DateTime.now().startOfDay.add(Duration(hours: 3)),
              dateUntil: DateTime.now().startOfDay.add(Duration(hours: 7)),
              isFullDay: false,
              color: Colors.purple,
            ),
            CnCalendarEntry(
              id: '0',
              title: 'Test',
              dateFrom: DateTime.now().startOfDay.add(Duration(hours: 3, minutes: 20)),
              dateUntil: DateTime.now().startOfDay.add(Duration(hours: 7)),
              isFullDay: true,
              color: Colors.red,
            ),
            CnCalendarEntry(
              id: '0',
              title: 'Test',
              dateFrom: DateTime.now().startOfDay.add(Duration(minutes: 30)),
              dateUntil: DateTime.now().startOfDay.add(Duration(hours: 4)),
              isFullDay: false,
              color: Colors.blue,
            ),
            CnCalendarEntry(
              id: '0',
              title: 'Test',
              dateFrom: DateTime.now().subtractDays(4).startOfDay.add(Duration(minutes: 30)),
              dateUntil: DateTime.now().subtractDays(4).startOfDay.add(Duration(hours: 4)),
              isFullDay: false,
              color: Colors.orange,
            ),
            CnCalendarEntry(
              id: '0',
              title: 'Test',
              dateFrom: DateTime.now().subtractDays(1).startOfDay.add(Duration(minutes: 30)),
              dateUntil: DateTime.now().subtractDays(1).startOfDay.add(Duration(hours: 4)),
              isFullDay: false,
              color: Colors.blue,
            ),
            CnCalendarEntry(
              id: '0',
              title: 'Test',
              dateFrom: DateTime.now().subtractDays(2),
              dateUntil: DateTime.now().startOfDay,
              isFullDay: true,
              color: Colors.orange,
            ),
            CnCalendarEntry(
              id: '0',
              title: 'Test',
              dateFrom: DateTime.now().startOfDay.add(Duration(hours: 6, minutes: 15)),
              dateUntil: DateTime.now().startOfDay.add(Duration(hours: 6, minutes: 30)),
              isFullDay: false,
              color: Colors.black,
            ),
            CnCalendarEntry(
              id: '0',
              title: 'Test',
              dateFrom: DateTime.now().startOfDay.add(Duration(hours: 6, minutes: 00)),
              dateUntil: DateTime.now().startOfDay.add(Duration(hours: 6, minutes: 15)),
              isFullDay: false,
              color: Colors.black,
            ),
            CnCalendarEntry(
              id: '0',
              title: 'Test',
              dateFrom: DateTime.now().startOfDay.add(Duration(hours: 6, minutes: 30)),
              dateUntil: DateTime.now().startOfDay.add(Duration(hours: 6, minutes: 45)),
              isFullDay: false,
              color: Colors.black,
            ),
            CnCalendarEntry(
              id: '0',
              title: 'Test',
              dateFrom: DateTime.now().startOfDay.add(Duration(hours: 6, minutes: 45)),
              dateUntil: DateTime.now().startOfDay.add(Duration(hours: 7)),
              isFullDay: false,
              color: Colors.black,
            ),
            CnCalendarEntry(
              id: '0',
              title: 'Test',
              dateFrom: DateTime.now().startOfDay.add(Duration(hours: 6, minutes: 50)),
              dateUntil: DateTime.now().startOfDay.add(Duration(hours: 7)),
              isFullDay: false,
              color: Colors.black,
            ),
            CnCalendarEntry(
              id: '0',
              title: 'Test',
              dateFrom: DateTime.now().startOfDay.add(Duration(hours: 4, minutes: 30)),
              dateUntil: DateTime.now().startOfDay.add(Duration(hours: 6)),
              isFullDay: false,
              color: Colors.green,
            ),
            // Test entry with very short duration (3 minutes) - should not show text
            CnCalendarEntry(
              id: '0',
              title: 'Short Entry',
              dateFrom: DateTime.now().startOfDay.add(Duration(hours: 8)),
              dateUntil: DateTime.now().startOfDay.add(Duration(hours: 8, minutes: 3)),
              isFullDay: false,
              color: Colors.red,
            ),
            // Test entry with exactly 5 minutes - should show text
            CnCalendarEntry(
              id: '0',
              title: '5 Min Entry',
              dateFrom: DateTime.now().startOfDay.add(Duration(hours: 9)),
              dateUntil: DateTime.now().startOfDay.add(Duration(hours: 9, minutes: 5)),
              isFullDay: false,
              color: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }
}
