import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:cn_calendar/views/month/widgets/cn_calendar_month_grid.dart';
import 'package:cn_calendar/views/month/widgets/cn_calendar_month_week_days.dart';
import 'package:flutter/material.dart';

class CnCalendarMonthView extends StatefulWidget {
  const CnCalendarMonthView({
    super.key,
    required this.selectedMonth,
    this.calendarEntries = const [],
    this.onDayTapped,
    this.onDateChanged,
    this.onTimeTapped,
  });

  /// Should always be the first day of the month
  final DateTime selectedMonth;

  /// Entries to be shown in the month view
  final List<CnCalendarEntry> calendarEntries;

  /// Called whenever a daycell is tapped
  final Function(DateTime date)? onDayTapped;

  /// Called whenever the PageView changes the month
  final Function(DateTime date)? onDateChanged;

  /// Called whenever a time slot is tapped
  /// This is useful for creating new entries at a specific time
  final Function(DateTime time)? onTimeTapped;

  @override
  State<CnCalendarMonthView> createState() => _CnCalendarMonthViewState();
}

class _CnCalendarMonthViewState extends State<CnCalendarMonthView> {
  late DateTime _currentMonth;
  late PageController _pageController;
  bool _isInternalUpdate = false;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.selectedMonth.firstDayOfMonth;
    _pageController = PageController(initialPage: 1);
  }

  @override
  void didUpdateWidget(CnCalendarMonthView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newMonth = widget.selectedMonth.firstDayOfMonth;
    if (oldWidget.selectedMonth.firstDayOfMonth != newMonth) {
      _isInternalUpdate = true;
      setState(() {
        _currentMonth = newMonth;
      });
      // Jump back to middle page after rebuilding
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(1);
          _isInternalUpdate = false;
        }
      });
    }
  }

  void _onPageChanged(int index) {
    if (_isInternalUpdate) return;

    if (index == 0) {
      // Swiped to previous month
      final newMonth = _currentMonth.addMonths(-1).firstDayOfMonth;
      setState(() {
        _currentMonth = newMonth;
      });
      _pageController.jumpToPage(1);
      widget.onDateChanged?.call(newMonth);
    } else if (index == 2) {
      // Swiped to next month
      final newMonth = _currentMonth.addMonths(1).firstDayOfMonth;
      setState(() {
        _currentMonth = newMonth;
      });
      _pageController.jumpToPage(1);
      widget.onDateChanged?.call(newMonth);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decoration = CnProvider.of(context).decoration;

    return Container(
      color: decoration.backgroundColor,
      child: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          _buildMonthPage(_currentMonth.addMonths(-1)),
          _buildMonthPage(_currentMonth),
          _buildMonthPage(_currentMonth.addMonths(1)),
        ],
      ),
    );
  }

  Widget _buildMonthPage(DateTime month) {
    return Column(
      children: [
        CnCalendarMonthWeekDays(),
        Expanded(
          child: CnCalendarMonthGrid(
            widget: CnCalendarMonthView(
              selectedMonth: month,
              calendarEntries: widget.calendarEntries,
              onDayTapped: widget.onDayTapped,
              onDateChanged: widget.onDateChanged,
              // Don't pass onTimeTapped to avoid unwanted calls
            ),
            calendarEntries: widget.calendarEntries,
            // Don't pass onTimeTapped to the grid to prevent unwanted triggering
          ),
        ),
      ],
    );
  }
}
