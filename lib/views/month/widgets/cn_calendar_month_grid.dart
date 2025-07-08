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
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        height = MediaQuery.sizeOf(context).height - MediaQuery.of(context).viewInsets.vertical;
      });
    });
  }

  List<Widget> build7x6Grid(double cellHeight, double cellWidth) {
    return List.generate(42, (index) {
      final int day =
          index - DateTime(widget.widget.selectedMonth.year, widget.widget.selectedMonth.month, 1).weekday + 2;
      final DateTime date = DateTime(widget.widget.selectedMonth.year, widget.widget.selectedMonth.month, day);

      // Get entries for this specific date
      final dateEntries = widget.calendarEntries
          .where((entry) => date.isBetween(entry.dateFrom.startOfDay, entry.dateUntil.endOfDay))
          .toList();

      return Positioned(
        top: (index / 7).floor() * cellHeight,
        left: (index % 7) * cellWidth,
        child: GestureDetector(
          onTap: () {
            widget.widget.onDayTapped?.call(date);
            widget.onTimeTapped?.call(date);
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
