import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';

/// Represents a positioned event in the month view
class PositionedMonthEvent {
  final CnCalendarEntry entry;
  final int row; // Which row this event is displayed in
  final int startCol; // Column where event starts (0-6 for Mon-Sun)
  final int span; // Number of columns this event spans in current week

  PositionedMonthEvent({required this.entry, required this.row, required this.startCol, required this.span});
}

/// Calculates the layout for multi-day events in a month view
/// This mimics Google Calendar's behavior where events are placed in rows
/// and events that don't fit show a "+X more" indicator
class CnCalendarMonthEventLayout {
  /// Calculate event positions for the entire month
  /// Returns a map of date -> list of positioned events for that date
  static Map<DateTime, List<PositionedMonthEvent>> calculateLayout({
    required DateTime monthStart,
    required List<CnCalendarEntry> entries,
    required int maxEventsPerDay,
  }) {
    final result = <DateTime, List<PositionedMonthEvent>>{};

    // Get the calendar grid dates (42 days: 6 weeks x 7 days)
    final gridDates = _getGridDates(monthStart);

    // Filter and sort full-day events
    final fullDayEvents = entries.where((e) => e.isFullDay).toList()
      ..sort((a, b) {
        // Sort by duration (longer events first) - this ensures consistent ordering
        final durationA = a.dateUntil.difference(a.dateFrom).inDays;
        final durationB = b.dateUntil.difference(b.dateFrom).inDays;
        final durationCompare = durationB.compareTo(durationA);
        if (durationCompare != 0) return durationCompare;

        // Then by start date
        final startCompare = a.dateFrom.compareTo(b.dateFrom);
        if (startCompare != 0) return startCompare;

        // Finally by title for stable sorting
        return a.title.compareTo(b.title);
      });

    // Assign global row numbers to events to maintain consistency across weeks
    final eventRowAssignments = <String, int>{};

    // Process events week by week
    for (int weekIndex = 0; weekIndex < 6; weekIndex++) {
      final weekDates = gridDates.skip(weekIndex * 7).take(7).toList();
      _layoutWeek(
        weekDates: weekDates,
        events: fullDayEvents,
        result: result,
        maxRows: maxEventsPerDay,
        eventRowAssignments: eventRowAssignments,
      );
    }

    return result;
  }

  /// Get all 42 dates for the month grid (6 weeks)
  static List<DateTime> _getGridDates(DateTime monthStart) {
    final dates = <DateTime>[];
    final firstDay = monthStart.firstDayOfMonth;
    final startOffset = firstDay.weekday - 1; // Monday = 0, Sunday = 6

    for (int i = 0; i < 42; i++) {
      final day = i - startOffset + 1;
      dates.add(DateTime(firstDay.year, firstDay.month, day));
    }

    return dates;
  }

  /// Layout events for a single week
  static void _layoutWeek({
    required List<DateTime> weekDates,
    required List<CnCalendarEntry> events,
    required Map<DateTime, List<PositionedMonthEvent>> result,
    required int maxRows,
    required Map<String, int> eventRowAssignments,
  }) {
    // Track which rows are occupied for each column
    final occupiedRows = List.generate(7, (_) => <int>{});

    // Process each event
    for (final event in events) {
      // Check if this event overlaps with this week
      final effectiveEnd = event.dateUntil.effectiveEndDate;
      final eventStart = event.dateFrom.startOfDay;
      final eventEnd = effectiveEnd.endOfDay;

      // Find dates in this week that the event spans
      final overlappingDates = <DateTime>[];
      for (final date in weekDates) {
        if ((date.isAtSameMomentAs(eventStart) || date.isAfter(eventStart)) &&
            (date.isAtSameMomentAs(eventEnd) || date.isBefore(eventEnd))) {
          overlappingDates.add(date);
        }
      }

      if (overlappingDates.isEmpty) continue;

      // Find the first available row for this event
      final startCol = weekDates.indexOf(overlappingDates.first);
      final endCol = weekDates.indexOf(overlappingDates.last);
      final span = endCol - startCol + 1;

      // Check if this event already has a row assigned from a previous week
      int? availableRow = eventRowAssignments[event.id];

      if (availableRow == null) {
        // Find first available row across all columns this event spans
        for (int row = 0; row < maxRows; row++) {
          bool rowAvailable = true;
          for (int col = startCol; col <= endCol; col++) {
            if (occupiedRows[col].contains(row)) {
              rowAvailable = false;
              break;
            }
          }
          if (rowAvailable) {
            availableRow = row;
            eventRowAssignments[event.id] = row; // Remember this assignment
            break;
          }
        }
      } else {
        // Event has a row assigned, but check if it's available in this week
        bool rowAvailable = true;
        for (int col = startCol; col <= endCol; col++) {
          if (occupiedRows[col].contains(availableRow)) {
            rowAvailable = false;
            break;
          }
        }

        // If the assigned row is occupied, try to find another one
        if (!rowAvailable) {
          availableRow = null;
          for (int row = 0; row < maxRows; row++) {
            bool available = true;
            for (int col = startCol; col <= endCol; col++) {
              if (occupiedRows[col].contains(row)) {
                available = false;
                break;
              }
            }
            if (available) {
              availableRow = row;
              // Update the assignment for this event
              eventRowAssignments[event.id] = row;
              break;
            }
          }
        }
      }

      // If no row available, skip this event (it will be in the "+X more" count)
      if (availableRow == null) continue;

      // Mark this row as occupied in all columns the event spans
      for (int col = startCol; col <= endCol; col++) {
        occupiedRows[col].add(availableRow);
      }

      // Add positioned event to each date it spans
      for (final date in overlappingDates) {
        result.putIfAbsent(date, () => []);
        result[date]!.add(PositionedMonthEvent(entry: event, row: availableRow, startCol: startCol, span: span));
      }
    }
  }

  /// Get the count of events that don't fit in the layout for a specific date
  static int getOverflowCount({
    required DateTime date,
    required List<CnCalendarEntry> allEntries,
    required Map<DateTime, List<PositionedMonthEvent>> layout,
  }) {
    // Get all full-day events for this date
    final fullDayEvents = allEntries.where((entry) {
      if (!entry.isFullDay) return false;
      final effectiveEnd = entry.dateUntil.effectiveEndDate;
      final startDay = entry.dateFrom.startOfDay;
      final endDay = effectiveEnd.endOfDay;
      return (date.isAtSameMomentAs(startDay) || date.isAfter(startDay)) &&
          (date.isAtSameMomentAs(endDay) || date.isBefore(endDay));
    }).toList();

    // Get positioned events for this date
    final positionedEvents = layout[date] ?? [];

    // Overflow count is the difference
    return fullDayEvents.length - positionedEvents.length;
  }
}
