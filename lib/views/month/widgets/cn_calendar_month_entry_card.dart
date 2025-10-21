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
    final effectiveEndDate = entry.dateUntil.effectiveEndDate;
    final isFirstDay = date.isSameDate(entry.dateFrom);
    final isLastDay = date.isSameDate(effectiveEndDate);
    final isSingleDay = entry.dateFrom.isSameDate(effectiveEndDate);

    // Single day event - round all corners
    if (isSingleDay) {
      return BorderRadius.circular(3);
    }

    // First day of multi-day event - round left corners
    if (isFirstDay) {
      return const BorderRadius.only(topLeft: Radius.circular(3), bottomLeft: Radius.circular(3));
    }

    // Last day of multi-day event - round right corners
    if (isLastDay) {
      return const BorderRadius.only(topRight: Radius.circular(3), bottomRight: Radius.circular(3));
    }

    // Middle day - no rounded corners
    return null;
  }

  bool showText() {
    final effectiveEndDate = entry.dateUntil.effectiveEndDate;
    final isSingleDay = entry.dateFrom.isSameDate(effectiveEndDate);

    // Always show text on single day events
    if (isSingleDay) return true;

    // Show text on first day of multi-day events
    if (date.isSameDate(entry.dateFrom)) return true;

    // Show text on Mondays for multi-day events that span into a new week
    if (date.weekday == DateTime.monday &&
        entry.dateFrom.isBefore(date) &&
        (effectiveEndDate.isAfter(date) || effectiveEndDate.isSameDate(date))) {
      return true;
    }

    return false;
  }

  EdgeInsets getPadding() {
    final effectiveEndDate = entry.dateUntil.effectiveEndDate;
    final isSingleDay = entry.dateFrom.isSameDate(effectiveEndDate);

    // Single day event - normal padding
    if (isSingleDay) {
      return const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0);
    }

    // Check if entry continues to previous/next day
    final continuesFromYesterday = entry.dateFrom.isBefore(date);
    final continuesToTomorrow = effectiveEndDate.isAfter(date);

    // Calculate horizontal padding based on continuation
    final double leftPadding = continuesFromYesterday ? 0.0 : 4.0;
    final double rightPadding = continuesToTomorrow ? 0.0 : 4.0;

    return EdgeInsets.only(left: leftPadding, right: rightPadding, top: 1.0, bottom: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(color: getColor(), borderRadius: getBorderRadius()),
      padding: getPadding(),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          showText() ? entry.title : '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 10),
        ),
      ),
    );
  }
}
