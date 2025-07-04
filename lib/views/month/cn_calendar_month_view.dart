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
  final PageController _pageController = PageController(initialPage: 1);

  DateTime firstMonthInPageView = DateTime.now().subtractMonths(1).firstDayOfMonth;

  @override
  Widget build(BuildContext context) {
    final decoration = CnProvider.of(context).decoration;

    return Container(
      color: decoration.backgroundColor,
      child: PageView.builder(
        itemCount: 3,
        controller: _pageController,
        onPageChanged: (value) {
          widget.onDateChanged?.call(firstMonthInPageView.addMonths(value).firstDayOfMonth);
        },
        itemBuilder: (context, index) {
          return Column(
            children: [
              CnCalendarMonthWeekDays(),
              Expanded(
                child: CnCalendarMonthGrid(
                  widget: widget,
                  calendarEntries: widget.calendarEntries,
                  onTimeTapped: widget.onTimeTapped,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
