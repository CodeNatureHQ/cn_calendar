import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/views/day/widgets/cn_calendar_day_entry_card.dart';
import 'package:flutter/material.dart';

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
  initState() {
    widget.calendarEntries.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int paintHours = 23;

    return Padding(
      padding: const EdgeInsets.only(left: 64),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return SizedBox(
            height: (paintHours + 4) * widget.hourHeight,
            child: Stack(
              children: [
                // Kalender-Einträge
                ...widget.calendarEntries.map((entry) {
                  final int alreadyRenderedEntriesAtSameTime =
                      widget.calendarEntries.where((e) => e.dateFrom == entry.dateFrom).length;

                  final startHour = entry.dateFrom.hour;
                  final startMinute = entry.dateFrom.minute;
                  final endHour = entry.dateUntil.hour;
                  final endMinute = entry.dateUntil.minute;

                  final top = startHour * widget.hourHeight + (startMinute / 60) * widget.hourHeight;
                  final height =
                      (endHour - startHour) * widget.hourHeight + (endMinute - startMinute) / 60 * widget.hourHeight;

                  final entryWidth = width / alreadyRenderedEntriesAtSameTime;

                  return Positioned(
                    top: top,
                    right: 0,
                    height: height,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: CnCalendarDayEntryCard(
                        entry: entry,
                        height: height,
                        // - 4 is used to prevent the shadow from being cut off
                        width: entryWidth - 4,
                        onTap: () {
                          widget.onEntryTapped?.call(entry);
                          entry.onTap?.call();
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
