import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:flutter/material.dart';

class CnCalendarMonthEntryCard extends StatelessWidget {
  const CnCalendarMonthEntryCard({super.key, required this.entry, required this.date, required this.selectedMonth});

  final CnCalendarEntry entry;
  final DateTime date;
  final DateTime selectedMonth;

  Color getColor() {
    if (date.month != selectedMonth.month) {
      return entry.color.withValues(alpha: 0.7);
    }

    return entry.color;
  }

  BorderRadius? getBorderRadius() {
    final int entryDuration = entry.dateUntil.difference(entry.dateFrom).inDays + 1;
    // if it is the only day of the entry => round all corners
    if (entryDuration == 1) {
      return BorderRadius.circular(4);
    }

    // if it is the first day of the entry and lasts longer than one day => round left corners
    if (date.isSameDate(entry.dateFrom) && entry.dateFrom.isBefore(entry.dateUntil)) {
      return BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4));
    }

    // if it is the last day of the entry and lasts longer than one day => round right corners
    if (date.isSameDate(entry.dateUntil) && entry.dateFrom.isBefore(entry.dateUntil)) {
      return BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4));
    }

    // if it is betweeen the first and last day of the entry and lasts equal or more than 3 days => no rounded corners
    return null;
  }

  bool showText() {
    final int entryDuration = entry.dateUntil.difference(entry.dateFrom).inDays + 1;
    return entryDuration == 1 || date.isSameDate(entry.dateFrom) || date.weekday == DateTime.monday;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(color: getColor(), borderRadius: getBorderRadius()),
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          showText() ? entry.title : '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 10),
        ),
      ),
    );
  }
}
