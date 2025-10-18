import 'package:coo_extensions/coo_extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  /// Adds days to the current date and returns a new DateTime object
  DateTime addDays(int days) {
    return DateTime(year, month, day + days, hour, minute, second, millisecond, microsecond);
  }

  /// Subracts days to the current date and returns a new DateTime object
  DateTime subtractDays(int days) {
    return addDays(days * -1);
  }

  /// Adds days to the current date and returns a new DateTime object with the start of the day
  bool isSameDate(DateTime? other) {
    return other != null && year == other.year && month == other.month && day == other.day;
  }

  /// Provides the timestamp of the start of given day in local time
  DateTime get startOfDay => DateTime(year, month, day, 0, 0, 0, 0, 0);

  /// Provides the timestamp of the end of given day in local time, so it is 1 ms before midnight
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999, 999);

  /// Provides the timestamp of the start of next day in local time
  DateTime get startOfNextDay {
    return addDays(1).startOfDay;
  }

  /// Return the first day of the week
  DateTime get firstDayOfWeek {
    final int weekDay = weekday;
    return subtract(Duration(days: weekDay - 1));
  }

  DateTime get firstDayOfMonth {
    return DateTime(year, month, 1);
  }

  TimeOfDay get timeOfDay {
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Returns true if the DateTime is at exactly midnight (0:00:00.000)
  bool get isMidnight {
    return hour == 0 && minute == 0 && second == 0 && millisecond == 0 && microsecond == 0;
  }

  /// For events that end at midnight, returns the previous day's end.
  /// Otherwise returns the endOfDay for the current date.
  /// This is used for display purposes to not show events on the day they end at midnight.
  DateTime get effectiveEndDate {
    if (isMidnight) {
      return subtract(Duration(microseconds: 1));
    }
    return this;
  }

  /// Indicates whether the DateTime object represents tomorrow's date.
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tomorrow.day == day && tomorrow.month == month && tomorrow.year == year;
  }

  /// Indicates whether two DateTime objects are in the same week.
  bool isSameWeek(DateTime date) {
    final weekDay = date.weekday;
    final weekStart = date.subtract(Duration(days: weekDay - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    return isBetween(weekStart, weekEnd);
  }

  DateTime get lastDayOfMonth {
    return DateTime(year, month + 1, 0);
  }

  /// Provides the amount of days between this and an [other] DateTime
  /// https://stackoverflow.com/questions/52713115/flutter-find-the-number-of-days-between-two-dates/67679455#67679455
  int numberOfRangeDays(DateTime other) {
    final DateTime from = DateTime(year, month, day);
    final DateTime to = DateTime(other.year, other.month, other.day);
    final int hours = from.isAfter(to) ? from.difference(to).inHours : to.difference(from).inHours;
    return (hours / 24).round() + 1;
  }

  /// Provides the amount of days from now to the given date
  int get daysFromNow => numberOfRangeDays(DateTime.now());

  /// Formats the date in common medium format for current locale eg. locale de --> 20.10.2023
  String get defaultDateFormat {
    const mediumFormat = 2;
    final intlDateFormats = DateFormat(null, Intl.getCurrentLocale().split('_').first).dateSymbols.DATEFORMATS;
    return DateFormat(intlDateFormats[mediumFormat]).format(this);
  }

  /// Formats the weekday name in short form for current locale eg. locale de --> Mo
  String get weekdayNameShort {
    return DateFormat('E', Intl.getCurrentLocale()).format(this);
  }

  bool get hasMonth6Rows {
    // Erstellt ein DateTime-Objekt für den ersten Tag des gegebenen Monats und Jahres
    DateTime firstDayOfMonth = DateTime(year, month, 1);

    // Ermittelt den letzten Tag des Monats
    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

    // Berechnet die Anzahl der Tage im Monat
    int daysInMonth = lastDayOfMonth.day;

    // Berechnet den Wochentag des ersten Tages (1 = Montag, 7 = Sonntag)
    int startWeekday = firstDayOfMonth.weekday;

    // Startet mit einer Woche
    int weeks = 1;

    // Berechnet die Anzahl der verbleibenden Tage nach dem ersten Tag
    int remainingDays = daysInMonth - (8 - startWeekday);

    // Fügt vollständige Wochen hinzu
    weeks += remainingDays ~/ 7;

    // Überprüft, ob nach den vollständigen Wochen noch Tage übrig sind
    if (remainingDays % 7 > 0) {
      weeks += 1;
    }

    return weeks > 5;
  }

  String date() {
    String pad(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${pad(day)}.${pad(month)}.$year';
  }

  DateTime subtractMonths(int i) {
    return DateTime(year, month - i, day);
  }

  DateTime addMonths(int i) {
    return DateTime(year, month + i, day);
  }

  int get weekOfYear {
    final DateTime firstDayOfYear = DateTime(year, 1, 1);
    final int days = difference(firstDayOfYear).inDays;
    return (days / 7).ceil();
  }

  DateTime roundUp({Duration delta = const Duration(minutes: 15)}) {
    final remainder = millisecondsSinceEpoch % delta.inMilliseconds;

    // If already on the mark, return as is
    if (remainder == 0) {
      return this;
    }

    // Round to nearest: if remainder is more than half the delta, round up, otherwise round down
    if (remainder >= delta.inMilliseconds / 2) {
      // Round up
      return DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch + delta.inMilliseconds - remainder);
    } else {
      // Round down
      return DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch - remainder);
    }
  }

  /// Returns true if the given range (rangeStart to rangeEnd) overlaps with the week of this date.
  bool overlapsWithWeek(DateTime rangeStart, DateTime rangeEnd) {
    final weekStart = firstDayOfWeek;
    final weekEnd = weekStart.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999, microseconds: 999),
    );
    return rangeStart.isBefore(weekEnd) && rangeEnd.isAfter(weekStart);
  }
}
