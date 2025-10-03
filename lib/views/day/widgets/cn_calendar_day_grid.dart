import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:cn_calendar/views/day/widgets/cn_calendar_day_entries.dart';
import 'package:cn_calendar/views/day/widgets/cn_calendar_day_timeline.dart';
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
  double _headerShrinkProgress = 0.0;

  @override
  void initState() {
    super.initState();

    // Calculate header height based on full day entries
    final fullDayEntries = widget.calendarEntries.where((entry) => entry.isFullDay).toList();
    final headerHeight = _calculateHeaderHeight(fullDayEntries, 0.0); // Use expanded height for initial calculation

    double initialOffset;
    if (DateTime.now().day == widget.selectedDay.day) {
      initialOffset = headerHeight + (DateTime.now().hour * (widget.hourHeight - 4));
    } else {
      // Default to 8am. Used 7.5 to show the time in the timeline
      initialOffset = headerHeight + (7.5 * widget.hourHeight - 4);
    }

    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final fullDayEntries = widget.calendarEntries.where((entry) => entry.isFullDay).toList();
    if (fullDayEntries.isEmpty) return;

    final maxShrink = 50.0; // How much to scroll before fully shrunk
    final scrollOffset = _scrollController.offset;
    final progress = (scrollOffset / maxShrink).clamp(0.0, 1.0);

    if (progress != _headerShrinkProgress) {
      setState(() {
        _headerShrinkProgress = progress;
      });
    }
  }

  void _handleTimeSlotTap(TapUpDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localOffset = box.globalToLocal(details.globalPosition);
    final scrollOffset = _scrollController.offset;

    // Account for the header height when calculating the time
    final fullDayEntries = widget.calendarEntries.where((entry) => entry.isFullDay).toList();
    final headerHeight = _calculateHeaderHeight(fullDayEntries, _headerShrinkProgress);

    final y = localOffset.dy + scrollOffset - headerHeight;
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

  double _calculateHeaderHeight(List<CnCalendarEntry> entries, double shrinkProgress) {
    if (entries.isEmpty) return 0.0;

    final entryHeight = 36.0 - (6.0 * shrinkProgress); // From 36 to 30
    final verticalPadding = 4.0 - (2.0 * shrinkProgress); // From 4 to 2
    final containerPadding = 8.0 - (4.0 * shrinkProgress); // From 8 to 4

    return (containerPadding * 2) + (entries.length * (entryHeight + (verticalPadding * 2)));
  }

  @override
  Widget build(BuildContext context) {
    final fullDayEntries = widget.calendarEntries.where((entry) => entry.isFullDay).toList();
    final timedEntries = widget.calendarEntries.where((entry) => !entry.isFullDay).toList();

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            if (fullDayEntries.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SizedBox(height: _calculateHeaderHeight(fullDayEntries, _headerShrinkProgress)),
              ),
              SliverToBoxAdapter(child: Divider(height: 1)),
            ],
            SliverToBoxAdapter(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: _handleTimeSlotTap,
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
            ),
          ],
        ),
        if (fullDayEntries.isNotEmpty)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _FullDayEntriesHeader(
              fullDayEntries: fullDayEntries,
              onEntryTapped: widget.onEntryTapped,
              shrinkProgress: _headerShrinkProgress,
            ),
          ),
      ],
    );
  }
}

class _FullDayEntriesHeader extends StatelessWidget {
  final List<CnCalendarEntry> fullDayEntries;
  final Function(CnCalendarEntry entry)? onEntryTapped;
  final double shrinkProgress;

  const _FullDayEntriesHeader({required this.fullDayEntries, this.onEntryTapped, this.shrinkProgress = 0.0});

  @override
  Widget build(BuildContext context) {
    // Interpolate values based on shrink progress
    final entryHeight = 36.0 - (6.0 * shrinkProgress); // From 36 to 30
    final verticalPadding = 4.0 - (2.0 * shrinkProgress); // From 4 to 2
    final fontSize = 14.0 - (2.0 * shrinkProgress); // From 14 to 12
    final borderRadius = 8.0 - (2.0 * shrinkProgress); // From 8 to 6
    final containerPadding = 8.0 - (4.0 * shrinkProgress); // From 8 to 4
    final maxLines = shrinkProgress > 0.5 ? 1 : 2; // Reduce lines when shrinking

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: containerPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: fullDayEntries.map((entry) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: verticalPadding),
              child: GestureDetector(
                onTap: () => onEntryTapped?.call(entry),
                child: Container(
                  height: entryHeight,
                  width: double.infinity,
                  padding: EdgeInsets.all(containerPadding),
                  decoration: BoxDecoration(
                    color: entry.color,
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25 - (0.05 * shrinkProgress)),
                        blurRadius: 4 - (1 * shrinkProgress),
                        offset: Offset(0, 4 - (1 * shrinkProgress)),
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child:
                        entry.content ??
                        Text(
                          entry.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: maxLines,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
