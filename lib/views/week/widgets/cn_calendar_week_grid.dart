import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/views/week/widgets/cn_calendar_week_day_entries.dart';
import 'package:cn_calendar/views/week/widgets/cn_calendar_week_timeline.dart';
import 'package:coo_extensions/coo_extensions.dart';
import 'package:flutter/material.dart';

class CnCalendarWeekGrid extends StatefulWidget {
  const CnCalendarWeekGrid({
    super.key,
    required this.selectedWeek,
    required this.calendarEntries,
    this.onEntryTapped,
    this.onTimeTapped,
  });

  final DateTime selectedWeek;
  final List<CnCalendarEntry> calendarEntries;
  final Function(CnCalendarEntry entry)? onEntryTapped;
  final Function(DateTime time)? onTimeTapped;

  @override
  State<CnCalendarWeekGrid> createState() => _CnCalendarWeekGridState();
}

class _CnCalendarWeekGridState extends State<CnCalendarWeekGrid> with SingleTickerProviderStateMixin {
  double hourHeight = 50;
  double scaleDamping = 0.01; // Further reduce damping for a more responsive scale gesture

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: DateTime.now().hour * hourHeight);
    super.initState();
  }

  List<CnCalendarEntry> getAllFullDayEvents() {
    return widget.calendarEntries.where((entry) => entry.isFullDay).toList();
  }

  void _handleTimeSlotTap(TapDownDetails details, DateTime day) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localOffset = box.globalToLocal(details.globalPosition);
    final scrollOffset = _scrollController.offset;
    final y = localOffset.dy + scrollOffset;
    final hour = y ~/ hourHeight;
    final minute = ((y % hourHeight) / hourHeight * 60).round();
    final tappedTime = DateTime(
      day.year,
      day.month,
      day.day,
      hour,
      minute,
    );
    widget.onTimeTapped?.call(tappedTime);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          // TODO Implement all events that lasts longer than a day with correct starting and ending times

          // TODO Implement all events that lasts a day and have a start and end time
          GestureDetector(
            // change height of hourHeight when pinching the screen
            onScaleUpdate: (details) {
              // Smoother scaling with a more responsive and immediate damping effect
              double adjustedScale = 1 + (details.scale - 1) * scaleDamping;

              // Neue Höhe mit Dämpfung berechnen und begrenzen
              hourHeight = (hourHeight * adjustedScale).clamp(50.0, 150.0);
              setState(() {});
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CnCalendarWeekTimeline(hourHeight: hourHeight),
                ),
                ...List.generate(
                  7,
                  (index) {
                    final selectedDate = widget.selectedWeek.add(Duration(days: index));
                    // Zeige alle Einträge für den Tag an und diese, die den Tag überlappen
                    List<CnCalendarEntry> entriesForDay = widget.calendarEntries
                        .where((entry) => selectedDate.isBetween(entry.dateFrom.startOfDay, entry.dateUntil.endOfDay))
                        .toList();

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapDown: (details) => _handleTimeSlotTap(details, selectedDate),
                        child: CnCalendarWeekDayEntries(
                          selectedDay: widget.selectedWeek.add(Duration(days: index)),
                          hourHeight: hourHeight,
                          calendarEntries: entriesForDay,
                          onEntryTapped: widget.onEntryTapped,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
