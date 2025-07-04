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
    this.onTimeTapped,
    this.hourHeight = 60,
  });

  final DateTime selectedDay;
  final List<CnCalendarEntry> calendarEntries;
  final Function(CnCalendarEntry entry)? onEntryTapped;
  final Function(DateTime time)? onTimeTapped;
  final double hourHeight;

  @override
  State<CnCalendarDayGrid> createState() => _CnCalendarDayGridState();
}

class _CnCalendarDayGridState extends State<CnCalendarDayGrid> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    if (DateTime.now().day == widget.selectedDay.day) {
      _scrollController = ScrollController(initialScrollOffset: DateTime.now().hour * (widget.hourHeight - 4));
    } else {
      // Default to 8am. Used 7.5 to show the time in the timeline
      _scrollController = ScrollController(initialScrollOffset: 7.5 * widget.hourHeight - 4);
    }

    super.initState();
  }

  void _handleTimeSlotTap(TapDownDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localOffset = box.globalToLocal(details.globalPosition);
    final scrollOffset = _scrollController.offset;
    final y = localOffset.dy + scrollOffset;
    final hour = y ~/ widget.hourHeight;
    final minute = ((y % widget.hourHeight) / widget.hourHeight * 60).round();
    final tappedTime = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
      hour,
      minute,
    );
    widget.onTimeTapped?.call(tappedTime);
  }

  @override
  Widget build(BuildContext context) {
    final fullDayEntries = widget.calendarEntries.where((entry) => entry.isFullDay).toList();
    final timedEntries = widget.calendarEntries.where((entry) => !entry.isFullDay).toList();
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
                child: CnCalendarFullDayEntryCard(entry: entry, width: double.infinity),
              ),
            );
          }),
          if (fullDayEntries.isNotEmpty) ...[SizedBox(height: 8), Divider()],
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: _handleTimeSlotTap,
            child: Stack(
              children: [
                CnCalendarDayTimeline(hourHeight: widget.hourHeight),
                CnCalendarDayEntriesList(
                  selectedDay: widget.selectedDay,
                  hourHeight: widget.hourHeight,
                  calendarEntries: timedEntries,
                  onEntryTapped: widget.onEntryTapped,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
