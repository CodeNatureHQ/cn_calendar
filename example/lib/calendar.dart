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
            // === EDGE CASE 1: Very long event spanning 3+ weeks ===
            CnCalendarEntry(
              id: '1',
              title: 'Mega Conference',
              dateFrom: DateTime.now().subtract(Duration(days: 10)).startOfDay,
              dateUntil: DateTime.now().add(Duration(days: 20)).endOfDay,
              isFullDay: true,
              color: Colors.deepPurple,
            ),

            // === EDGE CASE 2: Multiple overlapping events of different lengths ===
            CnCalendarEntry(
              id: '2',
              title: 'Long Vacation',
              dateFrom: DateTime.now().subtract(Duration(days: 2)).startOfDay,
              dateUntil: DateTime.now().add(Duration(days: 15)).endOfDay,
              isFullDay: true,
              color: Colors.green,
            ),
            CnCalendarEntry(
              id: '3',
              title: 'Project Sprint',
              dateFrom: DateTime.now().subtract(Duration(days: 1)).startOfDay,
              dateUntil: DateTime.now().add(Duration(days: 13)).endOfDay,
              isFullDay: true,
              color: Colors.purple,
            ),
            CnCalendarEntry(
              id: '4',
              title: 'Conference Week',
              dateFrom: DateTime.now().startOfDay,
              dateUntil: DateTime.now().add(Duration(days: 6)).endOfDay,
              isFullDay: true,
              color: Colors.blue,
            ),
            CnCalendarEntry(
              id: '5',
              title: 'Team Training',
              dateFrom: DateTime.now().add(Duration(days: 1)).startOfDay,
              dateUntil: DateTime.now().add(Duration(days: 3)).endOfDay,
              isFullDay: true,
              color: Colors.orange,
            ),

            // === EDGE CASE 3: Events starting on different weekdays ===
            CnCalendarEntry(
              id: '6',
              title: 'Monday Start',
              dateFrom: DateTime.now().add(Duration(days: 7 - DateTime.now().weekday + 1)).startOfDay, // Next Monday
              dateUntil: DateTime.now().add(Duration(days: 7 - DateTime.now().weekday + 5)).endOfDay, // Next Friday
              isFullDay: true,
              color: Colors.teal,
            ),
            CnCalendarEntry(
              id: '7',
              title: 'Wednesday Start',
              dateFrom: DateTime.now().add(Duration(days: 7 - DateTime.now().weekday + 3)).startOfDay, // Next Wednesday
              dateUntil:
                  DateTime.now().add(Duration(days: 7 - DateTime.now().weekday + 10)).endOfDay, // Following Wednesday
              isFullDay: true,
              color: Colors.cyan,
            ),
            CnCalendarEntry(
              id: '8',
              title: 'Friday Start',
              dateFrom: DateTime.now().add(Duration(days: 7 - DateTime.now().weekday + 5)).startOfDay, // Next Friday
              dateUntil:
                  DateTime.now().add(Duration(days: 7 - DateTime.now().weekday + 9)).endOfDay, // Following Tuesday
              isFullDay: true,
              color: Colors.pink,
            ),

            // === EDGE CASE 4: Weekend-spanning events ===
            CnCalendarEntry(
              id: '9',
              title: 'Weekend Event',
              dateFrom: DateTime.now().add(Duration(days: 7 - DateTime.now().weekday + 6)).startOfDay, // Next Saturday
              dateUntil: DateTime.now().add(Duration(days: 7 - DateTime.now().weekday + 7)).endOfDay, // Next Sunday
              isFullDay: true,
              color: Colors.red,
            ),
            CnCalendarEntry(
              id: '10',
              title: 'Long Weekend',
              dateFrom:
                  DateTime.now().add(Duration(days: 14 - DateTime.now().weekday + 5)).startOfDay, // Friday in 2 weeks
              dateUntil:
                  DateTime.now().add(Duration(days: 14 - DateTime.now().weekday + 8)).endOfDay, // Following Monday
              isFullDay: true,
              color: Colors.amber,
            ),

            // === EDGE CASE 5: Single-day events on different days ===
            CnCalendarEntry(
              id: '11',
              title: 'Single Day Today',
              dateFrom: DateTime.now().startOfDay,
              dateUntil: DateTime.now().endOfDay,
              isFullDay: true,
              color: Colors.indigo,
            ),
            CnCalendarEntry(
              id: '12',
              title: 'Single Day +3',
              dateFrom: DateTime.now().add(Duration(days: 3)).startOfDay,
              dateUntil: DateTime.now().add(Duration(days: 3)).endOfDay,
              isFullDay: true,
              color: Colors.lime,
            ),
            CnCalendarEntry(
              id: '13',
              title: 'Single Day +7',
              dateFrom: DateTime.now().add(Duration(days: 7)).startOfDay,
              dateUntil: DateTime.now().add(Duration(days: 7)).startOfDay,
              isFullDay: true,
              color: Colors.brown,
            ),

            // === EDGE CASE 6: Events with exactly 2 days (minimal multi-day) ===
            CnCalendarEntry(
              id: '14',
              title: 'Two Day Event A',
              dateFrom: DateTime.now().add(Duration(days: 4)).startOfDay,
              dateUntil: DateTime.now().add(Duration(days: 5)).endOfDay,
              isFullDay: true,
              color: Colors.deepOrange,
            ),
            CnCalendarEntry(
              id: '15',
              title: 'Two Day Event B',
              dateFrom: DateTime.now().add(Duration(days: 8)).startOfDay,
              dateUntil: DateTime.now().add(Duration(days: 9)).endOfDay,
              isFullDay: true,
              color: Colors.lightBlue,
            ),

            // === EDGE CASE 7: Events ending at midnight (effectiveEndDate test) ===
            CnCalendarEntry(
              id: '16',
              title: 'Midnight End Test',
              dateFrom: DateTime.now().add(Duration(days: 11)).startOfDay,
              dateUntil: DateTime.now().add(Duration(days: 13)).startOfDay, // Ends at midnight
              isFullDay: true,
              color: Colors.yellowAccent,
            ),

            // === EDGE CASE 8: Multiple events in same row (4+ events) ===
            CnCalendarEntry(
              id: '17',
              title: 'Row Test 1',
              dateFrom: DateTime.now().add(Duration(days: 16)).startOfDay,
              dateUntil: DateTime.now().add(Duration(days: 17)).endOfDay,
              isFullDay: true,
              color: Colors.blueGrey,
            ),
            CnCalendarEntry(
              id: '18',
              title: 'Row Test 2',
              dateFrom: DateTime.now().add(Duration(days: 18)).startOfDay,
              dateUntil: DateTime.now().add(Duration(days: 19)).endOfDay,
              isFullDay: true,
              color: Colors.grey,
            ),
            CnCalendarEntry(
              id: '19',
              title: 'Row Test 3',
              dateFrom: DateTime.now().add(Duration(days: 20)).startOfDay,
              dateUntil: DateTime.now().add(Duration(days: 21)).endOfDay,
              isFullDay: true,
              color: Colors.lightGreen,
            ),
            CnCalendarEntry(
              id: '20',
              title: 'Row Test 4 (Overflow)',
              dateFrom: DateTime.now().add(Duration(days: 16)).startOfDay,
              dateUntil: DateTime.now().add(Duration(days: 22)).endOfDay,
              isFullDay: true,
              color: Colors.pinkAccent,
            ),

            // === EDGE CASE 9: Events spanning exactly one week ===
            CnCalendarEntry(
              id: '21',
              title: 'Exactly One Week',
              dateFrom: DateTime.now().add(Duration(days: 23)).startOfDay,
              dateUntil: DateTime.now().add(Duration(days: 29)).endOfDay,
              isFullDay: true,
              color: Colors.deepOrange,
            ),

            // === EDGE CASE 10: Past events ===
            CnCalendarEntry(
              id: '22',
              title: 'Past Event',
              dateFrom: DateTime.now().subtract(Duration(days: 20)).startOfDay,
              dateUntil: DateTime.now().subtract(Duration(days: 15)).endOfDay,
              isFullDay: true,
              color: Colors.grey.shade400,
            ),

            // === EDGE CASE 11: Multi-day timed event (should display in header) ===
            CnCalendarEntry(
              id: '23',
              title: 'Multi-Day Conference (Timed)',
              dateFrom: DateTime.now().add(Duration(days: 2)).startOfDay.add(Duration(hours: 9)),
              dateUntil: DateTime.now().add(Duration(days: 5)).startOfDay.add(Duration(hours: 17)),
              isFullDay: false, // Not marked as full-day, but spans >24 hours
              color: Colors.teal,
            ),

            // Regular timed events for testing
            CnCalendarEntry(
              id: 'timed1',
              title: 'Morning Meeting',
              dateFrom: DateTime.now().startOfDay.add(Duration(hours: 9)),
              dateUntil: DateTime.now().startOfDay.add(Duration(hours: 10)),
              isFullDay: false,
              color: Colors.purple,
            ),
            CnCalendarEntry(
              id: 'timed2',
              title: 'Lunch Break',
              dateFrom: DateTime.now().startOfDay.add(Duration(hours: 12)),
              dateUntil: DateTime.now().startOfDay.add(Duration(hours: 13)),
              isFullDay: false,
              color: Colors.blue,
            ),
            CnCalendarEntry(
              id: 'timed3',
              title: 'Afternoon Session',
              dateFrom: DateTime.now().startOfDay.add(Duration(hours: 14)),
              dateUntil: DateTime.now().startOfDay.add(Duration(hours: 16)),
              isFullDay: false,
              color: Colors.orange,
            ),
            CnCalendarEntry(
              id: 'timed4',
              title: 'Evening Call',
              dateFrom: DateTime.now().startOfDay.add(Duration(hours: 17, minutes: 30)),
              dateUntil: DateTime.now().startOfDay.add(Duration(hours: 18)),
              isFullDay: false,
              color: Colors.red,
            ),

            // Appointments on different days
            CnCalendarEntry(
              id: 'timed5',
              title: 'Dentist',
              dateFrom: DateTime.now().add(Duration(days: 1)).startOfDay.add(Duration(hours: 10)),
              dateUntil: DateTime.now().add(Duration(days: 1)).startOfDay.add(Duration(hours: 11)),
              isFullDay: false,
              color: Colors.teal,
            ),
            CnCalendarEntry(
              id: 'timed6',
              title: 'Client Meeting',
              dateFrom: DateTime.now().add(Duration(days: 1)).startOfDay.add(Duration(hours: 14)),
              dateUntil: DateTime.now().add(Duration(days: 1)).startOfDay.add(Duration(hours: 15, minutes: 30)),
              isFullDay: false,
              color: Colors.indigo,
            ),
            CnCalendarEntry(
              id: 'timed7',
              title: 'Gym',
              dateFrom: DateTime.now().add(Duration(days: 2)).startOfDay.add(Duration(hours: 7)),
              dateUntil: DateTime.now().add(Duration(days: 2)).startOfDay.add(Duration(hours: 8)),
              isFullDay: false,
              color: Colors.green,
            ),
            CnCalendarEntry(
              id: 'timed8',
              title: 'Team Standup',
              dateFrom: DateTime.now().add(Duration(days: 2)).startOfDay.add(Duration(hours: 9, minutes: 30)),
              dateUntil: DateTime.now().add(Duration(days: 2)).startOfDay.add(Duration(hours: 10)),
              isFullDay: false,
              color: Colors.blue,
            ),
            CnCalendarEntry(
              id: 'timed9',
              title: 'Workshop',
              dateFrom: DateTime.now().add(Duration(days: 3)).startOfDay.add(Duration(hours: 13)),
              dateUntil: DateTime.now().add(Duration(days: 3)).startOfDay.add(Duration(hours: 17)),
              isFullDay: false,
              color: Colors.deepOrange,
            ),
            CnCalendarEntry(
              id: 'timed10',
              title: 'Coffee Chat',
              dateFrom: DateTime.now().add(Duration(days: 4)).startOfDay.add(Duration(hours: 11)),
              dateUntil: DateTime.now().add(Duration(days: 4)).startOfDay.add(Duration(hours: 11, minutes: 30)),
              isFullDay: false,
              color: Colors.brown,
            ),
            CnCalendarEntry(
              id: 'timed11',
              title: 'Code Review',
              dateFrom: DateTime.now().add(Duration(days: 5)).startOfDay.add(Duration(hours: 15)),
              dateUntil: DateTime.now().add(Duration(days: 5)).startOfDay.add(Duration(hours: 16)),
              isFullDay: false,
              color: Colors.cyan,
            ),
            CnCalendarEntry(
              id: 'timed12',
              title: 'Dinner Plans',
              dateFrom: DateTime.now().add(Duration(days: 6)).startOfDay.add(Duration(hours: 19)),
              dateUntil: DateTime.now().add(Duration(days: 6)).startOfDay.add(Duration(hours: 21)),
              isFullDay: false,
              color: Colors.pink,
            ),

            // Multiple events on same day to test overflow
            CnCalendarEntry(
              id: 'timed13',
              title: 'Planning Session',
              dateFrom: DateTime.now().add(Duration(days: 7)).startOfDay.add(Duration(hours: 9)),
              dateUntil: DateTime.now().add(Duration(days: 7)).startOfDay.add(Duration(hours: 10)),
              isFullDay: false,
              color: Colors.purple,
            ),
            CnCalendarEntry(
              id: 'timed14',
              title: 'Design Review',
              dateFrom: DateTime.now().add(Duration(days: 7)).startOfDay.add(Duration(hours: 11)),
              dateUntil: DateTime.now().add(Duration(days: 7)).startOfDay.add(Duration(hours: 12)),
              isFullDay: false,
              color: Colors.amber,
            ),
            CnCalendarEntry(
              id: 'timed15',
              title: 'Sprint Retrospective',
              dateFrom: DateTime.now().add(Duration(days: 7)).startOfDay.add(Duration(hours: 14)),
              dateUntil: DateTime.now().add(Duration(days: 7)).startOfDay.add(Duration(hours: 15)),
              isFullDay: false,
              color: Colors.lightBlue,
            ),
            CnCalendarEntry(
              id: 'timed16',
              title: 'All-Hands Meeting',
              dateFrom: DateTime.now().add(Duration(days: 7)).startOfDay.add(Duration(hours: 16)),
              dateUntil: DateTime.now().add(Duration(days: 7)).startOfDay.add(Duration(hours: 17)),
              isFullDay: false,
              color: Colors.deepPurple,
            ),

            // More appointments across the month
            CnCalendarEntry(
              id: 'timed17',
              title: 'Doctor Appointment',
              dateFrom: DateTime.now().add(Duration(days: 10)).startOfDay.add(Duration(hours: 9, minutes: 30)),
              dateUntil: DateTime.now().add(Duration(days: 10)).startOfDay.add(Duration(hours: 10, minutes: 30)),
              isFullDay: false,
              color: Colors.red,
            ),
            CnCalendarEntry(
              id: 'timed18',
              title: 'Lunch with Team',
              dateFrom: DateTime.now().add(Duration(days: 10)).startOfDay.add(Duration(hours: 12, minutes: 30)),
              dateUntil: DateTime.now().add(Duration(days: 10)).startOfDay.add(Duration(hours: 13, minutes: 30)),
              isFullDay: false,
              color: Colors.green,
            ),
            CnCalendarEntry(
              id: 'timed19',
              title: 'Product Demo',
              dateFrom: DateTime.now().add(Duration(days: 11)).startOfDay.add(Duration(hours: 10)),
              dateUntil: DateTime.now().add(Duration(days: 11)).startOfDay.add(Duration(hours: 11)),
              isFullDay: false,
              color: Colors.blue,
            ),
            CnCalendarEntry(
              id: 'timed20',
              title: 'Sales Call',
              dateFrom: DateTime.now().add(Duration(days: 11)).startOfDay.add(Duration(hours: 14)),
              dateUntil: DateTime.now().add(Duration(days: 11)).startOfDay.add(Duration(hours: 15)),
              isFullDay: false,
              color: Colors.orange,
            ),
            CnCalendarEntry(
              id: 'timed21',
              title: 'Training Workshop',
              dateFrom: DateTime.now().add(Duration(days: 12)).startOfDay.add(Duration(hours: 9)),
              dateUntil: DateTime.now().add(Duration(days: 12)).startOfDay.add(Duration(hours: 12)),
              isFullDay: false,
              color: Colors.purple,
            ),
            CnCalendarEntry(
              id: 'timed22',
              title: 'Team Lunch',
              dateFrom: DateTime.now().add(Duration(days: 12)).startOfDay.add(Duration(hours: 12, minutes: 30)),
              dateUntil: DateTime.now().add(Duration(days: 12)).startOfDay.add(Duration(hours: 13, minutes: 30)),
              isFullDay: false,
              color: Colors.pink,
            ),
            CnCalendarEntry(
              id: 'timed23',
              title: '1-on-1 with Manager',
              dateFrom: DateTime.now().add(Duration(days: 13)).startOfDay.add(Duration(hours: 15)),
              dateUntil: DateTime.now().add(Duration(days: 13)).startOfDay.add(Duration(hours: 16)),
              isFullDay: false,
              color: Colors.indigo,
            ),
            CnCalendarEntry(
              id: 'timed24',
              title: 'Project Kickoff',
              dateFrom: DateTime.now().add(Duration(days: 14)).startOfDay.add(Duration(hours: 10)),
              dateUntil: DateTime.now().add(Duration(days: 14)).startOfDay.add(Duration(hours: 11, minutes: 30)),
              isFullDay: false,
              color: Colors.teal,
            ),
            CnCalendarEntry(
              id: 'timed25',
              title: 'Budget Review',
              dateFrom: DateTime.now().add(Duration(days: 14)).startOfDay.add(Duration(hours: 14)),
              dateUntil: DateTime.now().add(Duration(days: 14)).startOfDay.add(Duration(hours: 15)),
              isFullDay: false,
              color: Colors.amber,
            ),

            // Week 3 appointments
            CnCalendarEntry(
              id: 'timed26',
              title: 'Team Standup',
              dateFrom: DateTime.now().add(Duration(days: 18)).startOfDay.add(Duration(hours: 9)),
              dateUntil: DateTime.now().add(Duration(days: 18)).startOfDay.add(Duration(hours: 9, minutes: 30)),
              isFullDay: false,
              color: Colors.blue,
            ),
            CnCalendarEntry(
              id: 'timed27',
              title: 'Partner Meeting',
              dateFrom: DateTime.now().add(Duration(days: 18)).startOfDay.add(Duration(hours: 11)),
              dateUntil: DateTime.now().add(Duration(days: 18)).startOfDay.add(Duration(hours: 12)),
              isFullDay: false,
              color: Colors.deepOrange,
            ),
            CnCalendarEntry(
              id: 'timed28',
              title: 'Infrastructure Review',
              dateFrom: DateTime.now().add(Duration(days: 19)).startOfDay.add(Duration(hours: 10)),
              dateUntil: DateTime.now().add(Duration(days: 19)).startOfDay.add(Duration(hours: 11)),
              isFullDay: false,
              color: Colors.cyan,
            ),
            CnCalendarEntry(
              id: 'timed29',
              title: 'Security Audit',
              dateFrom: DateTime.now().add(Duration(days: 19)).startOfDay.add(Duration(hours: 14)),
              dateUntil: DateTime.now().add(Duration(days: 19)).startOfDay.add(Duration(hours: 16)),
              isFullDay: false,
              color: Colors.red,
            ),
            CnCalendarEntry(
              id: 'timed30',
              title: 'Coffee Break',
              dateFrom: DateTime.now().add(Duration(days: 20)).startOfDay.add(Duration(hours: 10, minutes: 30)),
              dateUntil: DateTime.now().add(Duration(days: 20)).startOfDay.add(Duration(hours: 11)),
              isFullDay: false,
              color: Colors.brown,
            ),

            // More scattered appointments
            CnCalendarEntry(
              id: 'timed31',
              title: 'Yoga Class',
              dateFrom: DateTime.now().add(Duration(days: 8)).startOfDay.add(Duration(hours: 18)),
              dateUntil: DateTime.now().add(Duration(days: 8)).startOfDay.add(Duration(hours: 19)),
              isFullDay: false,
              color: Colors.green,
            ),
            CnCalendarEntry(
              id: 'timed32',
              title: 'Haircut',
              dateFrom: DateTime.now().add(Duration(days: 9)).startOfDay.add(Duration(hours: 16)),
              dateUntil: DateTime.now().add(Duration(days: 9)).startOfDay.add(Duration(hours: 17)),
              isFullDay: false,
              color: Colors.pink,
            ),
            CnCalendarEntry(
              id: 'timed33',
              title: 'Piano Lesson',
              dateFrom: DateTime.now().add(Duration(days: 15)).startOfDay.add(Duration(hours: 17)),
              dateUntil: DateTime.now().add(Duration(days: 15)).startOfDay.add(Duration(hours: 18)),
              isFullDay: false,
              color: Colors.purple,
            ),
            CnCalendarEntry(
              id: 'timed34',
              title: 'Book Club',
              dateFrom: DateTime.now().add(Duration(days: 16)).startOfDay.add(Duration(hours: 19)),
              dateUntil: DateTime.now().add(Duration(days: 16)).startOfDay.add(Duration(hours: 20, minutes: 30)),
              isFullDay: false,
              color: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }
}
