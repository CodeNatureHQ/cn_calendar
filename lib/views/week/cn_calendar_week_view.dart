import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:cn_calendar/views/week/widgets/cn_calendar_week_full_days_header.dart';
import 'package:cn_calendar/views/week/widgets/cn_calendar_week_grid.dart';
import 'package:cn_calendar/views/week/widgets/cn_calendar_week_week_days.dart';
import 'package:flutter/material.dart';

class CnCalendarWeekView extends StatelessWidget {
  const CnCalendarWeekView({
    super.key,
    required this.selectedWeek,
    this.calendarEntries = const [],
    this.onDateChanged,
    this.onEntryTapped,
    this.onDayTapped,
    this.onTimeTapped,
  });

  /// Should always be the first day of the week
  final DateTime selectedWeek;

  /// Entries to be shown in the month week
  final List<CnCalendarEntry> calendarEntries;

  /// Called whenever the PageView changes the week
  final Function(DateTime date)? onDateChanged;

  /// Called whenever an entry is tapped
  final Function(CnCalendarEntry entry)? onEntryTapped;

  /// Called whenever a day in the week days section is tapped
  final Function(DateTime date)? onDayTapped;

  /// Called whenever a time slot is tapped
  /// This is useful for creating new entries at a specific time
  final Function(DateTime time)? onTimeTapped;

  @override
  Widget build(BuildContext context) {
    final decoration = CnProvider.of(context).decoration;
    return Container(
      color: decoration.backgroundColor,
      child: _WeekViewWithSliverHeader(
        selectedWeek: selectedWeek,
        calendarEntries: calendarEntries,
        onDateChanged: onDateChanged,
        onEntryTapped: onEntryTapped,
        onDayTapped: onDayTapped,
        onTimeTapped: onTimeTapped,
        decoration: decoration,
      ),
    );
  }
}

class _WeekViewWithSliverHeader extends StatefulWidget {
  const _WeekViewWithSliverHeader({
    required this.selectedWeek,
    required this.calendarEntries,
    required this.decoration,
    this.onDateChanged,
    this.onEntryTapped,
    this.onDayTapped,
    this.onTimeTapped,
  });

  final DateTime selectedWeek;
  final List<CnCalendarEntry> calendarEntries;
  final Function(DateTime date)? onDateChanged;
  final Function(CnCalendarEntry entry)? onEntryTapped;
  final Function(DateTime date)? onDayTapped;
  final Function(DateTime time)? onTimeTapped;
  final decoration;

  @override
  State<_WeekViewWithSliverHeader> createState() => _WeekViewWithSliverHeaderState();
}

class _WeekViewWithSliverHeaderState extends State<_WeekViewWithSliverHeader> {
  ScrollController _scrollController = ScrollController();
  double _headerShrinkProgress = 0.0;

  @override
  void initState() {
    super.initState();

    // Calculate header height based on full day entries
    final fullDayEntries = widget.calendarEntries.where((entry) => entry.shouldDisplayAsFullDay).toList();
    final headerHeight = _calculateHeaderHeight(fullDayEntries, 0.0);

    double initialOffset;
    if (DateTime.now().day >= widget.selectedWeek.day &&
        DateTime.now().day < widget.selectedWeek.add(Duration(days: 7)).day) {
      initialOffset = headerHeight + (DateTime.now().hour * (widget.decoration.weekViewHourHeight - 4));
    } else {
      // Default to 8am. Used 7.5 to show the time in the timeline
      initialOffset = headerHeight + (7.5 * widget.decoration.weekViewHourHeight - 4);
    }

    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final fullDayEntries = widget.calendarEntries.where((entry) => entry.shouldDisplayAsFullDay).toList();
    if (fullDayEntries.isEmpty) return;

    final maxShrink = 50.0; // How much to scroll before fully shrunk
    final scrollOffset = _scrollController.offset;
    final progress = (scrollOffset / maxShrink).clamp(0.0, 1.0);

    if (progress != _headerShrinkProgress) {
      setState(() {
        _headerShrinkProgress = progress;
      });
    }
  }

  double _calculateHeaderHeight(List<CnCalendarEntry> entries, double shrinkProgress) {
    if (entries.isEmpty) return 0.0;

    // Calculate the number of rows needed for full day events
    final eventRows = _calculateEventRows(entries);
    final rowCount = eventRows.isEmpty ? 0 : (eventRows.values.reduce((a, b) => a > b ? a : b) + 1);

    final rowHeight = 26.0 - (2.0 * shrinkProgress); // From 26 to 24
    final containerPadding = 8.0 - (4.0 * shrinkProgress); // From 8 to 4

    return (containerPadding * 2) + (rowCount * rowHeight);
  }

  Map<CnCalendarEntry, int> _calculateEventRows(List<CnCalendarEntry> entries) {
    final weekStart = widget.selectedWeek.firstDayOfWeek.startOfDay;
    final weekEnd = weekStart.add(const Duration(days: 6)).startOfDay;

    // Filter and prepare events
    final visibleEvents = <Map<String, dynamic>>[];

    for (final entry in entries) {
      final eventStart = entry.dateFrom.startOfDay;
      // Use effectiveEndDate to handle events that end at midnight - they should not be shown on that day
      final eventEnd = entry.dateUntil.effectiveEndDate.startOfDay;

      // Clip to week
      final visibleStart = eventStart.isBefore(weekStart) ? weekStart : eventStart;
      final visibleEnd = eventEnd.isAfter(weekEnd) ? weekEnd : eventEnd;

      if (!visibleStart.isAfter(visibleEnd)) {
        final entryStartDay = visibleStart.difference(weekStart).inDays;
        final entryEndDay = visibleEnd.difference(weekStart).inDays;

        visibleEvents.add({'entry': entry, 'startDay': entryStartDay, 'endDay': entryEndDay});
      }
    }

    // Sort events by start day, then by duration (longer events first)
    visibleEvents.sort((a, b) {
      final startComparison = (a['startDay'] as int).compareTo(b['startDay'] as int);
      if (startComparison != 0) return startComparison;
      final aDuration = (a['endDay'] as int) - (a['startDay'] as int);
      final bDuration = (b['endDay'] as int) - (b['startDay'] as int);
      return bDuration.compareTo(aDuration); // Longer events first
    });

    // Track occupied days for each row
    final rows = <List<bool>>[];
    final eventToRow = <CnCalendarEntry, int>{};

    for (final eventData in visibleEvents) {
      final entry = eventData['entry'] as CnCalendarEntry;
      final startDay = eventData['startDay'] as int;
      final endDay = eventData['endDay'] as int;

      // Find the first row where this event fits
      int targetRow = -1;
      for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
        bool canFit = true;
        for (int day = startDay; day <= endDay; day++) {
          if (day < rows[rowIndex].length && rows[rowIndex][day]) {
            canFit = false;
            break;
          }
        }
        if (canFit) {
          targetRow = rowIndex;
          break;
        }
      }

      // If no existing row can fit the event, create a new row
      if (targetRow == -1) {
        targetRow = rows.length;
        rows.add(List.filled(7, false));
      }

      // Mark the days as occupied in the target row
      for (int day = startDay; day <= endDay; day++) {
        if (day < 7) {
          if (day >= rows[targetRow].length) {
            rows[targetRow].addAll(List.filled(day - rows[targetRow].length + 1, false));
          }
          rows[targetRow][day] = true;
        }
      }

      eventToRow[entry] = targetRow;
    }

    return eventToRow;
  }

  @override
  Widget build(BuildContext context) {
    final fullDayEntries = widget.calendarEntries.where((entry) => entry.shouldDisplayAsFullDay).toList();
    final timedEntries = widget.calendarEntries.where((entry) => !entry.shouldDisplayAsFullDay).toList();

    return Column(
      children: [
        CnCalendarWeekWeekDays(
          selectedWeek: widget.selectedWeek,
          onDayTapped: widget.onDayTapped,
          decoration: widget.decoration,
          entries: widget.calendarEntries,
        ),
        Expanded(
          child: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  if (fullDayEntries.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: SizedBox(height: _calculateHeaderHeight(fullDayEntries, _headerShrinkProgress)),
                    ),
                    SliverToBoxAdapter(child: Divider(height: 1)),
                  ],
                  SliverToBoxAdapter(
                    child: CnCalendarWeekGrid(
                      selectedWeek: widget.selectedWeek,
                      calendarEntries: timedEntries,
                      onEntryTapped: widget.onEntryTapped,
                      onTimeTapped: widget.onTimeTapped,
                      hourHeight: widget.decoration.weekViewHourHeight,
                    ),
                  ),
                ],
              ),
              if (fullDayEntries.isNotEmpty)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: WeekFullDayEntriesHeader(
                    selectedWeek: widget.selectedWeek,
                    fullDayEntries: fullDayEntries,
                    onEntryTapped: widget.onEntryTapped,
                    shrinkProgress: _headerShrinkProgress,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
