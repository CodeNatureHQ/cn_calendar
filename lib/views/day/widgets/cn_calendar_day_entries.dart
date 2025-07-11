import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/views/day/widgets/cn_calendar_day_entry_card.dart';
import 'package:flutter/material.dart';

/// All the entries for a day with the timeline divider every hour
class CnCalendarDayEntriesList extends StatelessWidget {
  const CnCalendarDayEntriesList({
    super.key,
    required this.selectedDay,
    required this.hourHeight,
    required this.calendarEntries,
    this.onEntryTapped,
  });

  final DateTime selectedDay;
  final double hourHeight;
  final List<CnCalendarEntry> calendarEntries;
  final Function(CnCalendarEntry entry)? onEntryTapped;

  @override
  Widget build(BuildContext context) {
    // The amount of hours to paint 0 and 24h is not seen
    int paintHours = 23;

    return Padding(
      padding: const EdgeInsets.only(left: 64),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return SizedBox(
            height: (paintHours + 4) * hourHeight,
            child: Stack(
              clipBehavior: Clip.none, // Allow overflow for small entries
              children: _buildEntries(width),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildEntries(double width) {
    List<CnCalendarEntryPosition> entryPositions = [];
    entryPositions = calendarEntries.map((entry) {
      return CnCalendarEntryPosition(entry: entry, dateFrom: entry.dateFrom, dateUntil: entry.dateUntil);
    }).toList();

    // Sort by dateFrom, then by duration (longer events first)
    entryPositions.sort((a, b) {
      int startComparison = a.entry.dateFrom.compareTo(b.entry.dateFrom);
      if (startComparison != 0) return startComparison;

      // If start times are equal, prioritize longer events (Google Calendar style)
      Duration aDuration = a.entry.dateUntil.difference(a.entry.dateFrom);
      Duration bDuration = b.entry.dateUntil.difference(b.entry.dateFrom);
      return bDuration.compareTo(aDuration);
    });

    // Group events into overlapping groups
    List<List<CnCalendarEntryPosition>> overlappingGroups = _groupOverlappingEvents(entryPositions);

    List<Widget> widgets = [];

    for (var group in overlappingGroups) {
      widgets.addAll(_layoutEventGroup(group, width));
    }

    return widgets;
  }

  /// Groups events that overlap with each other
  List<List<CnCalendarEntryPosition>> _groupOverlappingEvents(List<CnCalendarEntryPosition> entries) {
    List<List<CnCalendarEntryPosition>> groups = [];

    for (var entry in entries) {
      // Skip full-day entries for now (they should be handled separately)
      if (entry.entry.isFullDay) continue;

      bool addedToGroup = false;

      // Try to add to an existing group
      for (var group in groups) {
        if (_entryOverlapsWithGroup(entry, group)) {
          group.add(entry);
          addedToGroup = true;
          break;
        }
      }

      // If not added to any group, create a new group
      if (!addedToGroup) {
        groups.add([entry]);
      }
    }

    return groups;
  }

  /// Check if an entry overlaps with any entry in a group
  bool _entryOverlapsWithGroup(CnCalendarEntryPosition entry, List<CnCalendarEntryPosition> group) {
    for (var groupEntry in group) {
      if (entry.entry.dateFrom.isBefore(groupEntry.entry.dateUntil) &&
          entry.entry.dateUntil.isAfter(groupEntry.entry.dateFrom)) {
        return true;
      }
    }
    return false;
  }

  /// Layout a group of overlapping events using Google Calendar-inspired algorithm
  List<Widget> _layoutEventGroup(List<CnCalendarEntryPosition> group, double totalWidth) {
    if (group.isEmpty) return [];

    // For single events, use full width
    if (group.length == 1) {
      return [_buildSingleEventWidget(group.first, totalWidth, 0)];
    }

    // Calculate column assignments using a greedy algorithm
    List<List<CnCalendarEntryPosition>> columns = [];

    for (var entry in group) {
      int columnIndex = _findAvailableColumn(entry, columns);

      // Ensure we have enough columns
      while (columns.length <= columnIndex) {
        columns.add(<CnCalendarEntryPosition>[]);
      }

      columns[columnIndex].add(entry);
    }

    int totalColumns = columns.length;
    List<Widget> widgets = [];

    // Build widgets for each event
    for (int colIndex = 0; colIndex < columns.length; colIndex++) {
      for (var entry in columns[colIndex]) {
        // Calculate the actual width this event should occupy
        int span = _calculateEventSpan(entry, columns, colIndex);

        double eventWidth = (totalWidth / totalColumns) * span;
        double leftOffset = (totalWidth / totalColumns) * colIndex;

        widgets.add(_buildSingleEventWidget(entry, eventWidth, leftOffset));
      }
    }

    return widgets;
  }

  /// Find the first available column for an event
  int _findAvailableColumn(CnCalendarEntryPosition entry, List<List<CnCalendarEntryPosition>> columns) {
    for (int i = 0; i < columns.length; i++) {
      bool canFit = true;
      for (var columnEntry in columns[i]) {
        if (entry.entry.dateFrom.isBefore(columnEntry.entry.dateUntil) &&
            entry.entry.dateUntil.isAfter(columnEntry.entry.dateFrom)) {
          canFit = false;
          break;
        }
      }
      if (canFit) return i;
    }
    return columns.length; // New column needed
  }

  /// Calculate how many columns this event should span (Google Calendar style expansion)
  int _calculateEventSpan(CnCalendarEntryPosition entry, List<List<CnCalendarEntryPosition>> columns, int startColumn) {
    int span = 1;

    // Check if this event can expand to the right
    for (int col = startColumn + 1; col < columns.length; col++) {
      bool canExpand = true;

      // Check if any event in this column conflicts with our event
      for (var columnEntry in columns[col]) {
        if (entry.entry.dateFrom.isBefore(columnEntry.entry.dateUntil) &&
            entry.entry.dateUntil.isAfter(columnEntry.entry.dateFrom)) {
          canExpand = false;
          break;
        }
      }

      if (canExpand) {
        span++;
      } else {
        break; // Can't expand further
      }
    }

    return span;
  }

  /// Build a single event widget with proper positioning
  Widget _buildSingleEventWidget(CnCalendarEntryPosition entry, double width, double leftOffset) {
    int startHour = entry.dateFrom.hour;
    int startMinute = entry.dateFrom.minute;
    int endHour = entry.dateUntil.hour;
    int endMinute = entry.dateUntil.minute;

    // Adjust the start and end times for events that span over midnight
    if (entry.dateFrom.startOfDay.isBefore(selectedDay.startOfDay)) {
      startHour = 0;
      startMinute = 0;
    } else if (entry.dateUntil.startOfDay.isAfter(selectedDay.endOfDay)) {
      endHour = 23;
      endMinute = 59;
    }

    final top = startHour * hourHeight + (startMinute / 60) * hourHeight;

    // Calculate the height of the entry
    final calculatedHeight = (endHour - startHour) * hourHeight + (endMinute - startMinute) / 60 * hourHeight;

    // Ensure minimum height equivalent to 10 minutes for very short entries
    final minHeight = hourHeight / 6; // 10 minutes = 1/6 hour
    final height = calculatedHeight < minHeight ? minHeight : calculatedHeight;

    return Positioned(
      top: top,
      left: leftOffset,
      child: SizedBox(
        height: height,
        width: width,
        child: Padding(
          padding: const EdgeInsets.only(left: 2.0, right: 2.0),
          child: CnCalendarDayEntryCard(
            entry: entry.entry,
            height: height,
            // - 4 is used to prevent the shadow from being cut off
            width: width - 4,
            onTap: () {
              onEntryTapped?.call(entry.entry);
            },
          ),
        ),
      ),
    );
  }
}

/// The position of an entry in the calendar
/// This is used to calculate the position of the entry in the calendar
/// it is needed, since some entries can overlap over days
class CnCalendarEntryPosition {
  final CnCalendarEntry entry;
  final DateTime dateFrom;
  final DateTime dateUntil;

  CnCalendarEntryPosition({required this.entry, required this.dateFrom, required this.dateUntil});
}
