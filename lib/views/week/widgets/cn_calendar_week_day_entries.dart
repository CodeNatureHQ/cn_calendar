import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:cn_calendar/views/week/widgets/cn_calendar_week_entry_card.dart';
import 'package:flutter/material.dart';

class CnCalendarWeekDayEntries extends StatelessWidget {
  const CnCalendarWeekDayEntries({
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
    final decoration = CnProvider.of(context).decoration;
    int paintHours = 23;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Funktion zur Gruppierung von überlappenden Einträgen
        List<List<CnCalendarEntry>> groupOverlappingEntries(List<CnCalendarEntry> entries) {
          entries.sort((a, b) => a.dateFrom.compareTo(b.dateFrom)); // Nach Startzeit sortieren
          List<List<CnCalendarEntry>> groups = [];

          for (final entry in entries) {
            bool added = false;
            for (final group in groups) {
              // Prüfen, ob der Eintrag mit dem letzten Eintrag in der Gruppe überlappt
              if (group.last.dateUntil.isAfter(entry.dateFrom)) {
                group.add(entry);
                added = true;
                break;
              }
            }
            if (!added) {
              groups.add([entry]); // Neue Gruppe erstellen
            }
          }

          return groups;
        }

        final groupedEntries = groupOverlappingEntries(calendarEntries);

        return Container(
          height: (paintHours + 4) * hourHeight,
          decoration: BoxDecoration(
            color: decoration.backgroundColor,
            border: Border.symmetric(vertical: BorderSide(color: Colors.grey, width: 0.1)),
          ),
          child: Stack(
            children: [
              // Stundenlinien
              ...List.generate(paintHours, (index) {
                return Positioned(
                  top: (index + 1) * hourHeight,
                  left: 0,
                  right: 0,
                  child: Container(height: 0.1, color: Colors.grey),
                );
              }),

              // Kalender-Einträge
              ...groupedEntries.expand((group) {
                final groupSize = group.length;
                return group.asMap().entries.map((entryWithIndex) {
                  final entry = entryWithIndex.value;
                  final index = entryWithIndex.key;

                  int startHour = entry.dateFrom.hour;
                  int startMinute = entry.dateFrom.minute;
                  int endHour = entry.dateUntil.hour;
                  int endMinute = entry.dateUntil.minute;

                  // Adjust the start and end times for events that span over midnight from yesterday to today and today to tomorrow
                  if (entry.dateFrom.startOfDay.isBefore(selectedDay.startOfDay)) {
                    startHour = 0;
                    startMinute = 0;
                  } else if (entry.dateUntil.startOfDay.isAfter(selectedDay.endOfDay)) {
                    endHour = 23;
                    endMinute = 59;
                  }

                  final top = startHour * hourHeight + (startMinute / 60) * hourHeight;

                  // Calculate the height of the entry
                  final calculatedHeight =
                      (endHour - startHour) * hourHeight + (endMinute - startMinute) / 60 * hourHeight;

                  // Ensure minimum height equivalent to 15 minutes for very short entries
                  final minHeight = hourHeight / 4; // 15 minutes = 1/4 hour
                  final height = calculatedHeight < minHeight ? minHeight : calculatedHeight;

                  final entryWidth = width / groupSize; // Platz pro Eintrag
                  final left = index * entryWidth;

                  return Positioned(
                    top: top,
                    left: left,
                    width: entryWidth,
                    height: height,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0),
                      child: CnCalendarWeekEntryCard(
                        entry: entry,
                        height: height,
                        onTap: () => onEntryTapped?.call(entry),
                      ),
                    ),
                  );
                });
              }),
            ],
          ),
        );
      },
    );
  }
}
