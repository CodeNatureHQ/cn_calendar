import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:cn_calendar/views/day/widgets/cn_calendar_day_grid.dart';
import 'package:flutter/material.dart';

class CnCalendarDayView extends StatefulWidget {
  const CnCalendarDayView({
    super.key,
    required this.selectedDay,
    this.calendarEntries = const [],
    this.onDateChanged,
    this.onEntryTapped,
  });

  /// Should always be the first day of the week
  final DateTime selectedDay;

  /// Entries to be shown in the day view
  final List<CnCalendarEntry> calendarEntries;

  /// Called whenever the PageView changes the day
  final Function(DateTime date)? onDateChanged;

  /// Called whenever an entry is tapped
  final Function(CnCalendarEntry entry)? onEntryTapped;

  @override
  State<CnCalendarDayView> createState() => _CnCalendarDayViewState();
}

class _CnCalendarDayViewState extends State<CnCalendarDayView> {
  late PageController _pageController;
  late DateTime _currentDay;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1); // Start in der Mitte
    _currentDay = widget.selectedDay; // Startdatum übernehmen
  }

  void _onPageChanged(int index) {
    setState(() {
      if (index == 0) {
        // Zurückswipen: Gehe einen Tag zurück
        _currentDay = _currentDay.subtract(const Duration(days: 1));
        widget.onDateChanged?.call(_currentDay);
        _pageController.jumpToPage(1); // Springe zurück zur mittleren Seite
      } else if (index == 2) {
        // Vorwärtsswipen: Gehe einen Tag vor
        _currentDay = _currentDay.add(const Duration(days: 1));
        widget.onDateChanged?.call(_currentDay);
        _pageController.jumpToPage(1); // Springe zurück zur mittleren Seite
      }
    });
  }

  Widget _buildPage(DateTime day) {
    final decoration = CnProvider.of(context).decoration;

    return Container(
      color: decoration.backgroundColor,
      child: CnCalendarDayGrid(
        selectedDay: day,
        calendarEntries: widget.calendarEntries,
        onEntryTapped: widget.onEntryTapped,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      children: [
        _buildPage(_currentDay.subtract(const Duration(days: 1))), // Gestern
        _buildPage(_currentDay), // Heute
        _buildPage(_currentDay.add(const Duration(days: 1))), // Morgen
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
