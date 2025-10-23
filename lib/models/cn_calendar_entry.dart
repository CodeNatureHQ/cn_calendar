import 'package:cn_calendar/models/cn_calendar_entry_type.dart';
import 'package:flutter/material.dart';

class CnCalendarEntry {
  /// The unique identifier of the Entry
  final String id;

  /// The title of the Entry
  final String title;

  /// The type of the Entry
  final CnCalendarEntryType type;

  /// The date the Entry starts
  final DateTime dateFrom;

  /// The date the Entry ends. If it is the same day as dateFrom it is a one day event
  final DateTime dateUntil;

  /// If the Entry has a timestamp given set this value to true to handle it accordingly
  final bool hasTimeStamp;

  /// The Color the Entry card should have in the calendar
  final Color color;

  /// If the Entry is a full day event
  final bool isFullDay;

  /// The Image URL to display in the Entry card
  final String? imageUrl;

  /// If content it passed, it will be displayed in the Entry card instead of the default title and Time
  final Widget? content;

  CnCalendarEntry({
    required this.id,
    required this.title,
    this.type = CnCalendarEntryType.event,
    required this.dateFrom,
    required this.dateUntil,
    required this.isFullDay,
    this.imageUrl,
    this.hasTimeStamp = false,
    this.color = Colors.black,
    this.content,
  });

  /// Returns true if this event should be treated as a full-day event in the header.
  /// This includes:
  /// - Events explicitly marked as isFullDay = true
  /// - Multi-day timed events (duration > 24 hours)
  bool get shouldDisplayAsFullDay {
    if (isFullDay) return true;

    // Check if the event spans more than 24 hours
    final duration = dateUntil.difference(dateFrom);
    return duration.inHours >= 24;
  }
}
