import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:cn_calendar/views/week/widgets/cn_calendar_week_full_days_header.dart';
import 'package:cn_calendar/views/week/widgets/cn_calendar_week_week_days.dart';
import 'package:flutter/material.dart';

import 'widgets/cn_calendar_week_grid.dart';

class CnCalendarWeekView extends StatefulWidget {
  const CnCalendarWeekView({
    super.key,
    required this.selectedWeek,
    this.calendarEntries = const [],
    this.onDateChanged,
    this.onEntryTapped,
    this.onDayTapped,
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

  @override
  State<CnCalendarWeekView> createState() => _CnCalendarWeekViewState();
}

class _CnCalendarWeekViewState extends State<CnCalendarWeekView> {
  late PageController _pageController;

  late DateTime _currentWeek;

  @override
  void initState() {
    super.initState();
    // Start in the middle of the PageView and set the current week
    _pageController = PageController(initialPage: 1);
    _currentWeek = widget.selectedWeek;
  }

  void _onPageChanged(int index) {
    setState(() {
      if (index == 0) {
        // Zurückwischen: Gehe eine Woche zurück
        _currentWeek = _currentWeek.subtract(const Duration(days: 7));
        if (widget.onDateChanged != null) {
          widget.onDateChanged!(_currentWeek);
        }
        // Zurück zur mittleren Seite springen
        _pageController.jumpToPage(1);
      } else if (index == 2) {
        // Vorwärtswischen: Gehe eine Woche vor
        _currentWeek = _currentWeek.add(const Duration(days: 7));
        if (widget.onDateChanged != null) {
          widget.onDateChanged!(_currentWeek);
        }
        // Zurück zur mittleren Seite springen
        _pageController.jumpToPage(1);
      }
    });
  }

  Widget _buildPage(DateTime week) {
    final decoration = CnProvider.of(context).decoration;

    return Container(
      color: decoration.backgroundColor,
      child: Column(
        children: [
          CnCalendarWeekWeekDays(
            selectedWeek: week,
            onDayTapped: (day) {
              // Optional: Handling, wenn ein Tag in der Woche getippt wird
            },
            decoration: decoration,
          ),
          CnCalendarWeekFullDaysHeader(
            calendarEntries: widget.calendarEntries.where((entry) => entry.isFullDay).toList(),
          ),
          Expanded(
            child: CnCalendarWeekGrid(
              selectedWeek: week,
              calendarEntries: widget.calendarEntries.where((entry) => !entry.isFullDay).toList(),
              onEntryTapped: (entry) {
                // Optional: Handling, wenn ein Kalendereintrag getippt wird
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      children: [
        _buildPage(_currentWeek.subtract(const Duration(days: 7))), // Vorherige Woche
        _buildPage(_currentWeek), // Aktuelle Woche
        _buildPage(_currentWeek.add(const Duration(days: 7))), // Nächste Woche
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
