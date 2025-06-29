import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/models/cn_calendar_view.dart';
import 'package:cn_calendar/models/cn_decoration.dart';
import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:cn_calendar/views/day/cn_calendar_day_view.dart';
import 'package:cn_calendar/views/month/cn_calendar_month_view.dart';
import 'package:cn_calendar/views/week/cn_calendar_week_view.dart';
import 'package:cn_calendar/widgets/cn_calendar_header.dart';
import 'package:coo_extensions/coo_extensions.dart';
import 'package:flutter/material.dart';

class CnCalendar extends StatefulWidget {
  const CnCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.onViewChanged,
    this.initialView = CnCalendarView.week,
    this.showViewSelector = true,
    this.leadingHeaderWidget,
    this.maxPagesInPast = 10,
    this.maxPagesInFuture = 10,
    this.decoration,
    this.calendarEntries = const [],
    this.onMonthViewDayTapped,
    this.onEntryTapped,
    this.onTimeTapped,
    this.showMonthView = true,
    this.showWeekView = true,
    this.showDayView = true,
  });

  final DateTime selectedDate;

  /// The initial view of the calendar when it is first displayed
  final CnCalendarView initialView;

  /// Whether the view selector should be shown on the right side of the header
  final bool showViewSelector;

  /// Universal callback for date changes in the calendar
  /// When [CnCalendarView.month] is selected, date will be the first of the month
  /// When [CnCalendarView.week] is selected, date will be the first day of the week
  /// When [CnCalendarView.day] is selected, date will be the selected day
  final Function(DateTime date, CnCalendarView selectedView) onDateChanged;

  /// Callback for view changes in the calendar
  /// When [CnCalendarView.month] is selected, date will be the first of the month
  /// When [CnCalendarView.week] is selected, date will be the first day of the week
  /// When [CnCalendarView.day] is selected, date will be the selected day
  /// This callback is only called when the view is changed by the user
  final Function(DateTime date, CnCalendarView selectedView)? onViewChanged;
  final Icon? leadingHeaderWidget;

  /// Maximum number of [weeks] [month] or [days] in the past that can be navigated to from the current date
  final int maxPagesInPast;

  /// Maximum number of [weeks] [month] or [days] in the past that can be navigated to from the current date
  final int maxPagesInFuture;

  /// Decoration for the calendar
  /// Default is set to black and white.
  final CnDecoration? decoration;

  /// Entries to be shown in the month view
  final List<CnCalendarEntry> calendarEntries;

  /// What should happen when tapped on month view day
  final Function(DateTime day)? onMonthViewDayTapped;

  /// What should happen when tapped on an entry
  final Function(CnCalendarEntry entry)? onEntryTapped;

  /// What should happen when tapped on a time slot
  final Function(DateTime time)? onTimeTapped;

  // Show or hide the views in the selector
  final bool showMonthView;
  final bool showWeekView;
  final bool showDayView;

  @override
  State<CnCalendar> createState() => _CnCalendarState();
}

class _CnCalendarState extends State<CnCalendar> {
  CnCalendarView _selectedView = CnCalendarView.week;
  late PageController _pageController;
  DateTime _selectedDate = DateTime.now().startOfDay;
  Widget? shownView;

  @override
  void initState() {
    _pageController = PageController(initialPage: 1); // Start in der Mitte
    _selectedView = widget.initialView;
    _selectedDate = widget.selectedDate.startOfDay;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CnCalendar oldWidget) {
    _selectedDate = widget.selectedDate.startOfDay;
    super.didUpdateWidget(oldWidget);
  }

  List<CnCalendarEntry> getFilteredEntriesForView() {
    switch (_selectedView) {
      case CnCalendarView.month:
        return widget.calendarEntries.where((entry) {
          return entry.dateFrom.isSameMonth(_selectedDate);
        }).toList();
      case CnCalendarView.week:
        return widget.calendarEntries.where((entry) {
          return entry.dateFrom.isSameWeek(_selectedDate);
        }).toList();
      case CnCalendarView.day:
        return widget.calendarEntries.where((entry) {
          return _selectedDate.isBetween(entry.dateFrom, entry.dateUntil) || _selectedDate.isSameDate(entry.dateFrom);
        }).toList();
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      if (index == 0) {
        // Zurückwischen: Gehe eine Woche zurück
        _selectedDate = _selectedDate.subtract(Duration(days: viewLength()));
        // Zurück zur mittleren Seite springen
        _pageController.jumpToPage(1);
      } else if (index == 2) {
        // Vorwärtswischen: Gehe eine Woche vor
        _selectedDate = _selectedDate.add(Duration(days: viewLength()));

        // Zurück zur mittleren Seite springen
        _pageController.jumpToPage(1);
      }
      widget.onDateChanged(_selectedDate, _selectedView);
    });
  }

  int viewLength() {
    switch (_selectedView) {
      case CnCalendarView.month:
        return 30;
      case CnCalendarView.week:
        return 7;
      case CnCalendarView.day:
        return 1;
    }
  }

  Widget _buildPage(DateTime date) {
    switch (_selectedView) {
      case CnCalendarView.month:
        return CnCalendarMonthView(
          selectedMonth: date.firstDayOfMonth,
          calendarEntries: getFilteredEntriesForView(),
          onDateChanged: (date) => widget.onDateChanged(date, CnCalendarView.month),
          onDayTapped: (date) {
            _selectedView = CnCalendarView.day;
            _selectedDate = date;
            widget.onMonthViewDayTapped?.call(date);
            setState(() {});
          },
        );
      case CnCalendarView.week:
        return CnCalendarWeekView(
          selectedWeek: date.firstDayOfWeek,
          calendarEntries: getFilteredEntriesForView(),
          onEntryTapped: widget.onEntryTapped,
          onDateChanged: (date) => widget.onDateChanged(date, CnCalendarView.week),
          onDayTapped: (date) {
            _selectedView = CnCalendarView.day;
            _selectedDate = date;
            setState(() {});
          },
          onTimeTapped: widget.onTimeTapped,
        );
      case CnCalendarView.day:
        return CnCalendarDayView(
          selectedDay: date,
          calendarEntries: getFilteredEntriesForView(),
          onDateChanged: (date) => widget.onDateChanged(date, CnCalendarView.day),
          onEntryTapped: widget.onEntryTapped,
          onTimeTapped: widget.onTimeTapped,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CnProvider(
      decoration: widget.decoration ?? CnDecoration(),
      showMonthView: widget.showMonthView,
      showWeekView: widget.showWeekView,
      showDayView: widget.showDayView,
      child: Column(
        children: [
          CnCalendarHeader(
            selectedView: _selectedView,
            ledingWidget: widget.leadingHeaderWidget,
            selectedDate: _selectedDate,
            onViewChanged: (date, view) {
              _selectedView = view;
              widget.onViewChanged?.call(date, view);
              setState(() {});
            },
            onDateChanged: (date, view) {
              widget.onDateChanged.call(date, _selectedView);
            },
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildPage(_selectedDate.subtract(Duration(days: viewLength()))),
                _buildPage(_selectedDate),
                _buildPage(_selectedDate.add(Duration(days: viewLength()))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
