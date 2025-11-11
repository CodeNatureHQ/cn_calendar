import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/views/month/cn_calendar_month_view.dart';
import 'package:cn_calendar/views/month/widgets/cn_calendar_month_cell.dart';
import 'package:cn_calendar/views/month/widgets/cn_calendar_month_event_layout.dart';
import 'package:flutter/material.dart';

class CnCalendarMonthGrid extends StatefulWidget {
  const CnCalendarMonthGrid({super.key, required this.widget, this.calendarEntries = const [], this.onTimeTapped});

  final CnCalendarMonthView widget;
  final List<CnCalendarEntry> calendarEntries;
  final Function(DateTime)? onTimeTapped;

  @override
  State<CnCalendarMonthGrid> createState() => _CnCalendarMonthGridState();
}

class _CnCalendarMonthGridState extends State<CnCalendarMonthGrid> {
  Map<DateTime, List<PositionedMonthEvent>> eventLayout = {};

  @override
  void initState() {
    super.initState();
    _calculateLayout();
  }

  @override
  void didUpdateWidget(CnCalendarMonthGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.calendarEntries != widget.calendarEntries ||
        oldWidget.widget.selectedMonth != widget.widget.selectedMonth) {
      _calculateLayout();
    }
  }

  void _calculateLayout() {
    setState(() {
      eventLayout = CnCalendarMonthEventLayout.calculateLayout(
        monthStart: widget.widget.selectedMonth,
        entries: widget.calendarEntries,
        maxEventsPerDay: 3, // Maximum 3 event rows before showing "+X more"
      );
    });
  }

  List<Widget> _build7x6Grid(double cellHeight, double cellWidth) {
    final cells = <Widget>[];

    // Build cells in reverse order so earlier cells are rendered on top
    // This allows overflow text from earlier days to appear above later days
    for (int index = 41; index >= 0; index--) {
      final int day =
          index - DateTime(widget.widget.selectedMonth.year, widget.widget.selectedMonth.month, 1).weekday + 2;
      final DateTime date = DateTime(widget.widget.selectedMonth.year, widget.widget.selectedMonth.month, day);

      // Get positioned events for this date
      final positionedEvents = eventLayout[date] ?? [];

      // Get timed entries for this date (non-full-day events that are not multi-day)
      final timedEntries =
          widget.calendarEntries
              .where((entry) => !entry.shouldDisplayAsFullDay && entry.dateFrom.isSameDate(date))
              .toList()
            ..sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

      // Calculate overflow count
      final overflowCount = CnCalendarMonthEventLayout.getOverflowCount(
        date: date,
        allEntries: widget.calendarEntries,
        layout: eventLayout,
      );

      cells.add(
        Positioned(
          top: (index / 7).floor() * cellHeight,
          left: (index % 7) * cellWidth,
          child: GestureDetector(
            onTap: () {
              widget.widget.onDayTapped?.call(date);
            },
            child: SizedBox(
              height: cellHeight,
              width: cellWidth,
              child: CnCalendarMonthCell(
                hideTopBorder: index < 7,
                date: date,
                selectedMonth: widget.widget.selectedMonth,
                positionedEvents: positionedEvents,
                timedEntries: timedEntries,
                overflowCount: overflowCount,
                onDayTapped: widget.widget.onDayTapped,
              ),
            ),
          ),
        ),
      );
    }

    return cells;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cellHeight = constraints.maxHeight / 6;
        double cellWidth = constraints.maxWidth / 7;
        return Stack(children: _build7x6Grid(cellHeight, cellWidth));
      },
    );
  }
}
