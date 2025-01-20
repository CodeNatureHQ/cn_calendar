import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/views/day/widgets/cn_calendar_day_entry_card.dart';
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
      return CnCalendarEntryPosition(entry: entry);
    }).toList();

    // Sort by dateFrom
    entryPositions.sort((a, b) => a.entry.dateFrom.compareTo(b.entry.dateFrom));

    for (int i = 0; i < entryPositions.length; i++) {
      if (i == 0) continue;

      final entryA = entryPositions[i - 1].entry;
      final entryB = entryPositions[i].entry;

      if (entryB.dateFrom.difference(entryA.dateFrom).inMinutes < 30) {
        entryPositions[i].halvedCount++;
        continue;
      } else {
        entryPositions[i].intendCount++;
        continue;
      }
    }
    // Sort by most halvedCount and then by dateFrom
    entryPositions.sort((a, b) => a.halvedCount.compareTo(b.halvedCount));

    for (int i = 0; i < entryPositions.length; i++) {
      if (i == 0) continue;

      final entryA = entryPositions[i - 1].entry;
      final entryB = entryPositions[i].entry;

      // if endtime is overlapping with next start time
      if (entryA.dateUntil.isAfter(entryB.dateFrom)) {
        entryPositions[i].intendCount++;
      }
    }
    return entryPositions.map((entry) {
      final startHour = entry.entry.dateFrom.hour;
      final startMinute = entry.entry.dateFrom.minute;
      final endHour = entry.entry.dateUntil.hour;
      final endMinute = entry.entry.dateUntil.minute;

      final top = startHour * widget.hourHeight + (startMinute / 60) * widget.hourHeight;
      final height = (endHour - startHour) * widget.hourHeight + (endMinute - startMinute) / 60 * widget.hourHeight;

      final entryWidth = (width / entry.halvedCount) - (8 * entry.intendCount);

      return Positioned(
        top: top,
        right: 0,
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
}

class CnCalendarEntryPosition {
  final CnCalendarEntry entry;
  int halvedCount;
  int intendCount;

  CnCalendarEntryPosition({
    required this.entry,
    this.halvedCount = 1,
    this.intendCount = 1,
  });
}
