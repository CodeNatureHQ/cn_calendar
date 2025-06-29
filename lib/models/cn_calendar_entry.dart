import 'package:flutter/material.dart';

class CnCalendarEntry {
  /// The unique identifier of the Entry
  final String id;

  /// The title of the Entry
  final String title;

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

  CnCalendarEntry({
    required this.id,
    required this.title,
    required this.dateFrom,
    required this.dateUntil,
    required this.isFullDay,
    this.imageUrl,
    this.hasTimeStamp = false,
    this.color = Colors.black,
  });
}
