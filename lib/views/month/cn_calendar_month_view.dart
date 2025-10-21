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
  final PageController _pageController = PageController(initialPage: 500);
  late DateTime baseMonth; // The month that corresponds to page 500
  int currentPageIndex = 500;

  @override
  void initState() {
    super.initState();
    baseMonth = widget.selectedMonth.firstDayOfMonth;
  }

  @override
  void didUpdateWidget(CnCalendarMonthView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only update if the selectedMonth has changed from external source
    // and it's different from what we're currently displaying
    final newMonth = widget.selectedMonth.firstDayOfMonth;
    if (oldWidget.selectedMonth.firstDayOfMonth != newMonth) {
      // Calculate how many months we need to offset from current base
      final monthDifference = _calculateMonthDifference(baseMonth, newMonth);
      final targetPage = 500 + monthDifference;

      // Only animate if we're not already on the correct page
      if (currentPageIndex != targetPage) {
        baseMonth = newMonth;
        currentPageIndex = targetPage;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pageController.hasClients) {
            _pageController.animateToPage(
              targetPage,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    }
  }

  int _calculateMonthDifference(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + (to.month - from.month);
  }

  @override
  Widget build(BuildContext context) {
    final decoration = CnProvider.of(context).decoration;

    return Container(
      color: decoration.backgroundColor,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (value) {
          currentPageIndex = value;
          // Calculate the month offset from the base month
          final monthOffset = value - 500;
          final newMonth = baseMonth.addMonths(monthOffset);
          widget.onDateChanged?.call(newMonth);
        },
        itemBuilder: (context, index) {
          // Calculate the month to display based on the page index offset from base month
          final monthOffset = index - 500;
          final currentMonth = baseMonth.addMonths(monthOffset);

          return Column(
            children: [
              CnCalendarMonthWeekDays(),
              Expanded(
                child: CnCalendarMonthGrid(
                  widget: CnCalendarMonthView(
                    selectedMonth: currentMonth,
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
        },
      ),
    );
  }
}
