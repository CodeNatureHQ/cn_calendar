import 'package:calendar_view/calendar_view.dart';
import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:example/calendar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Color(0xFFEDEDE9),
      ),
      home: const Calendar(),
    );
  }
}

class CalendarPackage extends StatefulWidget {
  const CalendarPackage({super.key});

  @override
  State<CalendarPackage> createState() => _CalendarPackageState();
}

class _CalendarPackageState extends State<CalendarPackage> {
  final events = [
    CalendarEventData(
      title: 'Event 1',
      date: DateTime.now().startOfDay,
      startTime: DateTime.now().add(Duration(hours: 3, minutes: 30)),
      endTime: DateTime.now().add(Duration(hours: 6)),
    ),
    CalendarEventData(
      title: 'Event 2',
      date: DateTime.now().startOfDay,
      startTime: DateTime.now().add(Duration(hours: 4, minutes: 15)),
      endTime: DateTime.now().add(Duration(hours: 6)),
    ),
    CalendarEventData(
      title: 'Event 3',
      date: DateTime.now().startOfDay,
      startTime: DateTime.now().add(Duration(hours: 4, minutes: 40)),
      endTime: DateTime.now().add(Duration(hours: 7)),
    ),
    CalendarEventData(
      title: 'Event 2',
      date: DateTime.now().startOfDay,
      startTime: DateTime.now().add(Duration(hours: 4, minutes: 15)),
      endTime: DateTime.now().add(Duration(hours: 6)),
    ),
    CalendarEventData(
      title: 'Event 3',
      date: DateTime.now().startOfDay,
      startTime: DateTime.now().add(Duration(hours: 4, minutes: 40)),
      endTime: DateTime.now().add(Duration(hours: 7)),
    ),
    CalendarEventData(
      title: 'Event 2',
      date: DateTime.now().startOfDay,
      startTime: DateTime.now().add(Duration(hours: 4, minutes: 15)),
      endTime: DateTime.now().add(Duration(hours: 6)),
    ),
    CalendarEventData(
      title: 'Event 3',
      date: DateTime.now().startOfDay,
      startTime: DateTime.now().add(Duration(hours: 4, minutes: 40)),
      endTime: DateTime.now().add(Duration(hours: 7)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    CalendarControllerProvider.of(context).controller.addAll(events);
    return Scaffold(
      body: DayView(),
    );
  }
}
