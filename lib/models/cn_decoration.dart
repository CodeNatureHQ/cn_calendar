import 'package:flutter/material.dart';

/// Decoration for the calendar.
/// Default is set to black and white.
class CnDecoration {
  CnDecoration({
    this.backgroundColor = Colors.white,
    this.headerForegroundColor = Colors.black,
    this.headerBackgroundColor = Colors.white,
    this.horizontalHeaderPadding = 16,

    // Month View
    this.monthViewDayBackgroundColor = Colors.white,
    this.monthViewDayForegroundColor = Colors.black,
    this.monthViewDaySelectedBackgroundColor = Colors.white,
    this.monthViewDaySelectedForegroundColor = Colors.black,
    this.monthViewNotSelectedMonthBackgroundColor = const Color(0xFFFAFAFE),
    this.monthViewSelectedMonthBorderColor = Colors.grey,
    this.monthViewNotSelectedMonthBorderColor = const Color.fromARGB(255, 185, 180, 180),
    this.monthViewTodayBackgroundColor = Colors.black,
    this.monthViewTodayForegroundColor = Colors.white,
    this.monthViewOverflowTextColor = const Color(0xFF888888),
    this.monthViewTimedEventTextColor = Colors.white,
    this.entryDotColor = Colors.white,
    this.entryDotColorActiveDay = Colors.black,
    this.weekViewHourHeight = 60.0,

    // Day View
    this.dayViewBackgroundColor = Colors.white,
    this.timelineLinesColor = Colors.grey,
    this.timelineTextColor = Colors.black,

    // Icons
    this.headerSelectViewIcon = Icons.calendar_month_outlined,
    this.headerSelectViewIconColor = Colors.black,

    // Week daysHeader
    this.weekDaysHeaderForegroundColor = Colors.black,
    this.weekDaysHeaderSelectedBackgroundColor = Colors.black,
    this.weekDaysHeaderSelectedForegroundColor = Colors.white,

    // MISC
    this.dayViewHourHeight = 60.0,
  });

  // COLORS #############################Color.fromARGB(255, 183, 183, 183)########################################################

  /// The overall background color of the calendar
  final Color backgroundColor;

  /// The color of the text in the header
  final Color headerForegroundColor;

  /// The background color of the header
  final Color headerBackgroundColor;

  // Month View #######################################################################################################
  final Color monthViewDayBackgroundColor;
  final Color monthViewDayForegroundColor;
  final Color monthViewDaySelectedBackgroundColor;
  final Color monthViewDaySelectedForegroundColor;
  final Color monthViewNotSelectedMonthBackgroundColor;
  final Color monthViewSelectedMonthBorderColor;
  final Color monthViewNotSelectedMonthBorderColor;
  final Color monthViewTodayBackgroundColor;
  final Color monthViewTodayForegroundColor;
  final Color monthViewOverflowTextColor;
  final Color monthViewTimedEventTextColor;
  final Color entryDotColor;
  final Color entryDotColorActiveDay;
  final double weekViewHourHeight;

  // Day View #########################################################################################################
  final Color dayViewBackgroundColor;

  // Timeline #########################################################################################################
  final Color timelineLinesColor;
  final Color timelineTextColor;

  // TEXT STYLES #######################################################################################################

  // Spacing ###########################################################################################################
  final double horizontalHeaderPadding;

  // Header ############################################################################################################
  final IconData headerSelectViewIcon;
  final Color headerSelectViewIconColor;

  // Week daysHeader ###################################################################################################
  final Color weekDaysHeaderForegroundColor;
  final Color weekDaysHeaderSelectedBackgroundColor;
  final Color weekDaysHeaderSelectedForegroundColor;

  // MISC ############################################################################################################
  /// Height of the hour in the day view
  final double dayViewHourHeight;
}
