import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:cn_calendar/views/week/widgets/cn_calendar_week_entry_card.dart';
import 'package:flutter/material.dart';

class CnCalendarWeekDayEntries extends StatelessWidget {
  const CnCalendarWeekDayEntries({
    super.key,
    required this.hourHeight,
    required this.calendarEntries,
    this.onEntryTapped,
  });

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
        List<List<CnCalendarEntry>> groupOverlappingEntries(
          List<CnCalendarEntry> entries,
        ) {
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
            border: Border.symmetric(
              vertical: BorderSide(
                color: Colors.grey,
                width: 0.1,
              ),
            ),
          ),
          child: Stack(
            children: [
              // Stundenlinien
              ...List.generate(
                paintHours,
                (index) {
                  return Positioned(
                    top: (index + 1) * hourHeight,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 0.1,
                      color: Colors.grey,
                    ),
                  );
                },
              ),

              // Kalender-Einträge
              ...groupedEntries.expand((group) {
                final groupSize = group.length;
                return group.asMap().entries.map((entryWithIndex) {
                  final entry = entryWithIndex.value;
                  final index = entryWithIndex.key;

                  final startHour = entry.dateFrom.hour;
                  final startMinute = entry.dateFrom.minute;
                  final endHour = entry.dateUntil.hour;
                  final endMinute = entry.dateUntil.minute;

                  final top = startHour * hourHeight + (startMinute / 60) * hourHeight;
                  final height = (endHour - startHour) * hourHeight + (endMinute - startMinute) / 60 * hourHeight;

                  final entryWidth = width / groupSize; // Platz pro Eintrag
                  final left = index * entryWidth;

                  return Positioned(
                    top: top,
                    left: left,
                    width: entryWidth,
                    height: height,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
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
