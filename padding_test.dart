// Test for improved padding on full-day events and "+X weitere" indicator

import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/models/cn_calendar_entry_type.dart';
import 'package:cn_calendar/models/cn_decoration.dart';
import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:cn_calendar/views/month/cn_calendar_month_view.dart';
import 'package:flutter/material.dart';

void main() => runApp(PaddingTestApp());

class PaddingTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PaddingTest(),
    );
  }
}

class PaddingTest extends StatefulWidget {
  @override
  _PaddingTestState createState() => _PaddingTestState();
}

class _PaddingTestState extends State<PaddingTest> {
  DateTime selectedMonth = DateTime(2025, 10, 1);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Padding Test - Multi-day Events'),
      ),
      body: CnProvider(
        decoration: CnDecoration(),
        showMonthView: true,
        showWeekView: false,
        showDayView: false,
        child: CnCalendarMonthView(
          selectedMonth: selectedMonth,
          calendarEntries: [
            // Day with many events to test "+X weitere" padding
            ...List.generate(8, (index) => CnCalendarEntry(
              id: 'single-$index',
              type: CnCalendarEntryType.event,
              title: 'Event ${index + 1}',
              dateFrom: DateTime(2025, 10, 15),
              dateUntil: DateTime(2025, 10, 15),
              hasTimeStamp: false,
              color: Colors.blue.withOpacity(0.8),
              isFullDay: true,
            )),
            
            // Multi-day event to test start/end padding
            CnCalendarEntry(
              id: 'multi-day',
              type: CnCalendarEntryType.event,
              title: 'Conference Week',
              dateFrom: DateTime(2025, 10, 20),
              dateUntil: DateTime(2025, 10, 24),
              hasTimeStamp: false,
              color: Colors.green,
              isFullDay: true,
            ),
            
            // Another multi-day event
            CnCalendarEntry(
              id: 'vacation',
              type: CnCalendarEntryType.event,
              title: 'Vacation',
              dateFrom: DateTime(2025, 10, 25),
              dateUntil: DateTime(2025, 10, 28),
              hasTimeStamp: false,
              color: Colors.orange,
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