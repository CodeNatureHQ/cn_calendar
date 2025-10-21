import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/views/month/cn_calendar_month_view.dart';
import 'package:cn_calendar/views/month/widgets/cn_calendar_month_cell.dart';
import 'package:coo_extensions/coo_extensions.dart';
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
  double height = 0;
  Map<String, int> eventPositions = {}; // Maps event IDs to their vertical positions

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        height = MediaQuery.sizeOf(context).height - MediaQuery.of(context).viewInsets.vertical;
      });
    });
    _calculateEventPositions();
  }

  @override
  void didUpdateWidget(CnCalendarMonthGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.calendarEntries != widget.calendarEntries) {
      _calculateEventPositions();
    }
  }

  void _calculateEventPositions() {
    eventPositions.clear();

    // Get all multi-day events
    final multiDayEvents = widget.calendarEntries
        .where((entry) => entry.dateUntil.difference(entry.dateFrom).inDays > 0)
        .toList();

    // Sort multi-day events by start date, then by duration (longest first)
    multiDayEvents.sort((a, b) {
      final startComparison = a.dateFrom.compareTo(b.dateFrom);
      if (startComparison != 0) return startComparison;
      return b.dateUntil.difference(b.dateFrom).inDays.compareTo(a.dateUntil.difference(a.dateFrom).inDays);
    });

    // Assign positions to multi-day events
    int currentPosition = 0;
    for (final event in multiDayEvents) {
      if (!eventPositions.containsKey(event.id)) {
        eventPositions[event.id] = currentPosition++;
      }
    }
  }

  List<Widget> build7x6Grid(double cellHeight, double cellWidth) {
    return List.generate(42, (index) {
      final int day =
          index - DateTime(widget.widget.selectedMonth.year, widget.widget.selectedMonth.month, 1).weekday + 2;
      final DateTime date = DateTime(widget.widget.selectedMonth.year, widget.widget.selectedMonth.month, day);

      // Get entries for this specific date
      // Use effectiveEndDate to handle events that end at midnight
      final dateEntries = widget.calendarEntries
          .where((entry) => date.isBetween(entry.dateFrom.startOfDay, entry.dateUntil.effectiveEndDate.endOfDay))
          .toList();

      return Positioned(
        top: (index / 7).floor() * cellHeight,
        left: (index % 7) * cellWidth,
        child: GestureDetector(
          onTap: () {
            widget.widget.onDayTapped?.call(date);
            // Removed onTimeTapped call - this should only be called for specific time slots, not day cells
          },
          child: SizedBox(
            height: cellHeight,
            width: cellWidth,
            child: CnCalendarMonthCell(
              hideTopBorder: index < 7,
              date: date,
              selectedMonth: widget.widget.selectedMonth,
              calendarEntries: dateEntries,
              onDayTapped: widget.widget.onDayTapped,
              eventPositions: eventPositions,
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cellHeight = constraints.maxHeight / 6;
        double cellWidth = constraints.maxWidth / 7;
        return Stack(children: build7x6Grid(cellHeight, cellWidth));
      },
    );
  }
}
