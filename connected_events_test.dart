// Test for connected multi-day events with overlapping events

import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/models/cn_calendar_entry_type.dart';
import 'package:cn_calendar/models/cn_decoration.dart';
import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:cn_calendar/views/month/cn_calendar_month_view.dart';
import 'package:flutter/material.dart';

void main() => runApp(ConnectedEventsTestApp());

class ConnectedEventsTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ConnectedEventsTest(),
    );
  }
}

class ConnectedEventsTest extends StatefulWidget {
  @override
  _ConnectedEventsTestState createState() => _ConnectedEventsTestState();
}

class _ConnectedEventsTestState extends State<ConnectedEventsTest> {
  DateTime selectedMonth = DateTime(2025, 10, 1);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connected Multi-Day Events Test'),
      ),
      body: CnProvider(
        decoration: CnDecoration(),
        showMonthView: true,
        showWeekView: false,
        showDayView: false,
        child: CnCalendarMonthView(
          selectedMonth: selectedMonth,
          calendarEntries: [
            // 5-day conference (should stay connected)
            CnCalendarEntry(
              id: 'conference',
              type: CnCalendarEntryType.event,
              title: 'Tech Conference',
              dateFrom: DateTime(2025, 10, 20),
              dateUntil: DateTime(2025, 10, 24),
              hasTimeStamp: false,
              color: Colors.blue,
              isFullDay: true,
            ),
            // Single day meeting on day 2 of conference
            CnCalendarEntry(
              id: 'meeting-1',
              type: CnCalendarEntryType.event,
              title: 'Team Meeting',
              dateFrom: DateTime(2025, 10, 21),
              dateUntil: DateTime(2025, 10, 21),
              hasTimeStamp: false,
              color: Colors.green,
              isFullDay: true,
            ),
            // Single day event on day 3 of conference
            CnCalendarEntry(
              id: 'workshop',
              type: CnCalendarEntryType.event,
              title: 'Workshop',
              dateFrom: DateTime(2025, 10, 22),
              dateUntil: DateTime(2025, 10, 22),
              hasTimeStamp: false,
              color: Colors.orange,
              isFullDay: true,
            ),
            // Another 3-day event overlapping (should also stay connected)
            CnCalendarEntry(
              id: 'training',
              type: CnCalendarEntryType.event,
              title: 'Training Session',
              dateFrom: DateTime(2025, 10, 22),
              dateUntil: DateTime(2025, 10, 24),
              hasTimeStamp: false,
              color: Colors.purple,
              isFullDay: true,
            ),
            // Single event on the last day
            CnCalendarEntry(
              id: 'presentation',
              type: CnCalendarEntryType.event,
              title: 'Final Presentation',
              dateFrom: DateTime(2025, 10, 24),
              dateUntil: DateTime(2025, 10, 24),
              hasTimeStamp: false,
              color: Colors.red,
              isFullDay: true,
            ),
          ],
          onDayTapped: (date) {
            print('Day tapped: ${date.day}/${date.month}');
          },
          onDateChanged: (date) {
            setState(() {
              selectedMonth = date;
            });
          },
        ),
      ),
    );
  }
}