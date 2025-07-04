import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/views/month/cn_calendar_month_view.dart';
import 'package:cn_calendar/views/month/widgets/cn_calendar_month_cell.dart';
import 'package:cn_calendar/views/month/widgets/cn_calendar_month_entry_card.dart';
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
      return Positioned(
        top: (index / 7).floor() * cellHeight,
        left: (index % 7) * cellWidth,
        child: GestureDetector(
          onTap: () {
            widget.widget.onDayTapped?.call(date);
            widget.onTimeTapped?.call(date); // Add onTimeTapped callback for month view
          },
          child: SizedBox(
            height: cellHeight,
            width: cellWidth,
            child: CnCalendarMonthCell(
              hideTopBorder: index < 7,
              date: date,
              selectedMonth: widget.widget.selectedMonth,
              calendarEntries: widget.widget.calendarEntries
                  .where((entry) => date.isBetween(entry.dateFrom.startOfDay, entry.dateUntil.endOfDay))
                  .toList(),
            ),
          ),
        ),
      );
    });
  }

  // TODO TESTSSS
  List<DateTime> allDatesBetween(DateTime from, DateTime to) {
    final List<DateTime> dates = [];
    for (int i = 0; i <= to.difference(from).inDays; i++) {
      dates.add(DateUtils.dateOnly(from.add(Duration(days: i))));
    }
    return dates;
  }

  List<Widget> placeEntriesOnGrid(BuildContext context, double cellHeight, double cellWidth) {
    final double entryCardHeight = 16;

    Map<DateTime, int> placedEntriesCount = {};

    List<Widget> entryCards = [];
    for (int i = 0; i < widget.calendarEntries.length; i++) {
      CnCalendarEntry entry = widget.calendarEntries[i];
      final int week = 1;

      List<DateTime> dates = allDatesBetween(entry.dateFrom, entry.dateUntil);
      for (DateTime date in dates) {
        placedEntriesCount[date] = (placedEntriesCount[date] ?? 0) + 1;
      }

      final int highest = allDatesBetween(
        entry.dateFrom,
        entry.dateUntil,
      ).map((date) => placedEntriesCount[date] ?? 0).reduce((value, element) => value > element ? value : element);

      if (highest > 3) {}

      Widget entryCard = Positioned(
        top: week * cellHeight + 30 + (18 * highest),
        left: 2 + (entry.dateFrom.weekday - 1) * cellWidth,
        child: SizedBox(
          height: entryCardHeight,
          width: cellWidth - 4,
          child: CnCalendarMonthEntryCard(
            entry: entry,
            date: entry.dateFrom,
            selectedMonth: widget.widget.selectedMonth,
          ),
        ),
      );
      entryCards.add(entryCard);
    }
    return entryCards;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cellHeight = constraints.maxHeight / 6;
        double cellWidth = constraints.maxWidth / 7;
        return Stack(
          children: [...build7x6Grid(cellHeight, cellWidth), ...placeEntriesOnGrid(context, cellHeight, cellWidth)],
        );
      },
    );
  }
}
