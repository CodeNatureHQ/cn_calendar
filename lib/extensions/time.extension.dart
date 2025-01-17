import 'package:flutter/material.dart';

extension TimeExtension on TimeOfDay {
  bool isAfter(TimeOfDay other) {
    if (hour > other.hour) {
      return true;
    } else if (hour == other.hour) {
      return minute > other.minute;
    }
    return false;
  }
}
