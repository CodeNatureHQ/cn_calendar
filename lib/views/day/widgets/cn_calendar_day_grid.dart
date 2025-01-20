import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/views/day/widgets/cn_calendar_day_entries.dart';
import 'package:cn_calendar/views/day/widgets/cn_calendar_day_timeline.dart';
import 'package:cn_calendar/widgets/cn_calendar_full_day_entry_card.dart';
import 'package:flutter/material.dart';

class CnCalendarDayGrid extends StatefulWidget {
  const CnCalendarDayGrid({
    super.key,
    required this.selectedDay,
    required this.calendarEntries,
    this.onEntryTapped,
  });

  final DateTime selectedDay;
  final List<CnCalendarEntry> calendarEntries;
  final Function(CnCalendarEntry entry)? onEntryTapped;

  @override
  State<CnCalendarDayGrid> createState() => _CnCalendarDayGridState();
}

class _CnCalendarDayGridState extends State<CnCalendarDayGrid> {
  ScrollController _scrollController = ScrollController();
  double hourHeight = 70;

  @override
  void initState() {
    if (DateTime.now().day == widget.selectedDay.day) {
      _scrollController = ScrollController(initialScrollOffset: DateTime.now().hour * hourHeight);
    } else {
      // Default to 8am. Used 7.5 to show the time in the timeline
      _scrollController = ScrollController(initialScrollOffset: 7.5 * hourHeight);
    }

    super.initState();
  }

  List<CnCalendarEntry> getAllFullDayEvents() {
    return widget.calendarEntries.where((entry) => entry.isFullDay).toList();
  }

  @override
  Widget build(BuildContext context) {
    double hourHeight = 70;
    final fullDayEntries = getAllFullDayEvents();
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          SizedBox(height: 16),
          ...fullDayEntries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: GestureDetector(
                onTap: () => widget.onEntryTapped?.call(entry),
                child: CnCalendarFullDayEntryCard(
                  entry: entry,
                  width: double.infinity,
                ),
              ),
            );
          }),
          if (fullDayEntries.isNotEmpty) ...[
            SizedBox(height: 16),
            Divider(),
          ],
          Stack(
            children: [
              CnCalendarDayTimeline(hourHeight: hourHeight),
              CnCalendarDayEntriesList(
                hourHeight: hourHeight,
                calendarEntries: widget.calendarEntries,
                onEntryTapped: widget.onEntryTapped,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
