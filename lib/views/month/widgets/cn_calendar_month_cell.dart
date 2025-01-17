import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/models/cn_decoration.dart';
import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:cn_calendar/views/month/widgets/cn_calendar_month_entry_card.dart';
import 'package:flutter/material.dart';

class CnCalendarMonthCell extends StatelessWidget {
  const CnCalendarMonthCell({
    super.key,
    required this.date,
    required this.selectedMonth,
    this.calendarEntries = const [],
    this.hideTopBorder = false,
  });

  final DateTime date;
  final DateTime selectedMonth;
  final List<CnCalendarEntry> calendarEntries;
  final bool hideTopBorder;

  /// Only show the first three entries in the grid cell and the rest will come in dots
  Widget getFirstThreeEntries() {
    /// Calendarentries are sorted by duration longest to shortest
    calendarEntries
        .sort((a, b) => a.dateFrom.difference(a.dateUntil).inDays.compareTo(b.dateFrom.difference(b.dateUntil).inDays));

    return Column(
      children: calendarEntries.take(3).map((entry) {
        return Padding(
          padding: getPadding(entry),
          child: CnCalendarMonthEntryCard(entry: entry, date: date, selectedMonth: selectedMonth),
        );
      }).toList(),
    );
  }

  /// Padding for the entry card depending on the duration and position during the dates of the entry
  EdgeInsets getPadding(CnCalendarEntry entry) {
    final int entryDuration = entry.dateFrom.difference(entry.dateUntil).inDays + 1;

    // if it is the only day of the entry => set padding const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0);
    if (entryDuration == 1) {
      return const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0);
    }

    // if it is the first day of the entry and lasts longer than one day => set padding const EdgeInsets.only(left: 2.0, bottom: 2.0);
    if (date.isSameDate(entry.dateFrom) && entry.dateFrom.isBefore(entry.dateUntil)) {
      return const EdgeInsets.only(left: 2.0, bottom: 2.0);
    }
    // if it is the last day of the entry and lasts longer than one day => set padding const EdgeInsets.only(right: 2.0, bottom: 2.0);

    if (date.isSameDate(entry.dateUntil) && entry.dateFrom.isBefore(entry.dateUntil)) {
      return const EdgeInsets.only(right: 2.0, bottom: 2.0);
    }

    //  if it is betweeen the first and last day of the entry and lasts equal or more than 3 days => set padding const EdgeInsets.only(bottom: 2.0);
    return const EdgeInsets.only(bottom: 2.0);
  }

  /// List all entries in dots that cannot be shown in the list
  Widget getMoreEntries() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: calendarEntries.skip(3).map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: entry.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// The decoration of the day cell
  BoxDecoration getBoxDecoration(CnDecoration decoration) {
    Color cellColor = decoration.monthViewDayBackgroundColor;
    Color borderColor = decoration.monthViewSelectedMonthBorderColor;

    if (date.isSameDate(DateTime.now())) {
      cellColor = decoration.monthViewDaySelectedBackgroundColor;
    } else if (date.month == selectedMonth.month) {
      cellColor = decoration.monthViewDayBackgroundColor;
      borderColor = decoration.monthViewSelectedMonthBorderColor;
    } else {
      cellColor = decoration.monthViewNotSelectedMonthBackgroundColor;
      borderColor = decoration.monthViewNotSelectedMonthBorderColor;
    }

    return BoxDecoration(
      color: cellColor,
      border: Border(
        top: BorderSide(
          color: hideTopBorder ? Colors.transparent : borderColor,
          width: 0.2,
        ),
        left: BorderSide(
          color: borderColor,
          width: 0.2,
        ),
        right: BorderSide(
          color: borderColor,
          width: 0.2,
        ),
        bottom: BorderSide(
          color: borderColor,
          width: 0.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final decoration = CnProvider.of(context).decoration;
    return Container(
      decoration: getBoxDecoration(decoration),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.only(top: 4),
          clipBehavior: Clip.none,
          decoration: BoxDecoration(
            color: date.isSameDate(DateTime.now()) ? Colors.black : null,
            shape: BoxShape.circle,
          ),
          child: Text(
            date.day.toString(),
            textAlign: TextAlign.center,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: date.isSameDate(DateTime.now())
                  ? Colors.white
                  : date.month == selectedMonth.month
                      ? Colors.black
                      : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
