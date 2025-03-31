import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/views/day/widgets/cn_calendar_day_entry_card.dart';
import 'package:coo_extensions/coo_extensions.dart';
import 'package:flutter/material.dart';

/// All the entries for a day with the timeline divider every hour
class CnCalendarDayEntriesList extends StatefulWidget {
  const CnCalendarDayEntriesList({
    super.key,
    required this.hourHeight,
    required this.calendarEntries,
    this.onEntryTapped,
  });

  final double hourHeight;
  final List<CnCalendarEntry> calendarEntries;
  final Function(CnCalendarEntry entry)? onEntryTapped;

  @override
  State<CnCalendarDayEntriesList> createState() => _CnCalendarDayEntriesListState();
}

class _CnCalendarDayEntriesListState extends State<CnCalendarDayEntriesList> {
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
            height: (paintHours + 4) * widget.hourHeight,
            child: Stack(
              children: _buildEntries(width),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildEntries(double width) {
    List<CnCalendarEntryPosition> entryPositions = [];
    entryPositions = widget.calendarEntries.map((entry) {
      return CnCalendarEntryPosition(
        entry: entry,
        dateFrom: entry.dateFrom,
        dateUntil: entry.dateUntil,
      );
    }).toList();

    // Sort by dateFrom
    entryPositions.sort((a, b) => a.entry.dateFrom.compareTo(b.entry.dateFrom));

    // Group entries into columns
    List<List<CnCalendarEntryPosition>> columns = [];
    for (var entry in entryPositions) {
      bool placed = false;
      for (var column in columns) {
        if (!_overlapsWithColumn(entry, column)) {
          column.add(entry);
          placed = true;
          break;
        }
      }
      if (!placed) {
        columns.add([entry]);
      }
    }

    // Calculate the maximum number of columns to determine the width of each entry
    int maxColumns = columns.length;

    return entryPositions.map((entry) {
      int startHour = entry.dateFrom.hour;
      int startMinute = entry.dateFrom.minute;
      int endHour = entry.dateUntil.hour;
      int endMinute = entry.dateUntil.minute;

      // Adjust the start and end times for events that span over midnight from yesterday to today and today to tomorrow
      if (entry.dateFrom.startOfDay.isYesterday) {
        startHour = 0;
        startMinute = 0;
      } else if (entry.dateUntil.startOfDay.isTomorrow) {
        endHour = 23;
        endMinute = 59;
      }

      final top = startHour * widget.hourHeight + (startMinute / 60) * widget.hourHeight;

      // Calculate the height of the entry
      final height = (endHour - startHour) * widget.hourHeight + (endMinute - startMinute) / 60 * widget.hourHeight;

      // Find the column index for this entry
      int columnIndex = 0;
      for (int i = 0; i < columns.length; i++) {
        if (columns[i].contains(entry)) {
          columnIndex = i;
          break;
        }
      }

      // Calculate the width and left position based on the column index
      final entryWidth = width / maxColumns;
      final left = columnIndex * entryWidth;

      return Positioned(
        top: top,
        left: left,
        height: height,
        child: Padding(
          padding: const EdgeInsets.only(left: 2.0),
          child: CnCalendarDayEntryCard(
            entry: entry.entry,
            height: height,
            // - 4 is used to prevent the shadow from being cut off
            width: entryWidth - 4,
            onTap: () {
              widget.onEntryTapped?.call(entry.entry);
              entry.entry.onTap?.call();
            },
          ),
        ),
      );
    }).toList();
  }

  /// Check if an entry overlaps with any entry in a column
  bool _overlapsWithColumn(CnCalendarEntryPosition entry, List<CnCalendarEntryPosition> column) {
    for (var existingEntry in column) {
      if (entry.entry.dateFrom.isBefore(existingEntry.entry.dateUntil) &&
          entry.entry.dateUntil.isAfter(existingEntry.entry.dateFrom)) {
        return true;
      }
    }
    return false;
  }
}

/// The position of an entry in the calendar
/// This is used to calculate the position of the entry in the calendar
/// it is needed, since some entries can overlap over days
class CnCalendarEntryPosition {
  final CnCalendarEntry entry;
  final DateTime dateFrom;
  final DateTime dateUntil;

  CnCalendarEntryPosition({
    required this.entry,
    required this.dateFrom,
    required this.dateUntil,
  });
}
