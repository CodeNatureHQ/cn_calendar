import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_view.dart';
import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:cn_calendar/widgets/cn_calendar_view_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The header of the calendar
/// Contains the date and the view picker
class CnCalendarHeader extends StatefulWidget {
  const CnCalendarHeader({
    super.key,
    required this.onDateChanged,
    required this.selectedView,
    required this.selectedDate,
    this.onViewChanged,
    this.leadingWidget,
    this.onHeaderTap,
    this.onLeadingTap,
  });

  /// Callback for date changes in the calendar
  final Function(DateTime date, CnCalendarView selectedView) onDateChanged;

  /// Callback for view changes in the calendar [CnCalendarView.month], [CnCalendarView.week], [CnCalendarView.day]
  final Function(DateTime date, CnCalendarView selectedView)? onViewChanged;

  /// The selected view of the calendar
  final CnCalendarView selectedView;

  /// The selected date in the calendar
  /// Depending on the selectd view the date is always the beginning of the month or view
  final DateTime selectedDate;

  /// Leading widget in the header
  final Widget? leadingWidget;

  /// Callback for header tap
  final VoidCallback? onHeaderTap;

  /// Callback for leading widget tap
  final VoidCallback? onLeadingTap;

  @override
  State<CnCalendarHeader> createState() => _CnCalendarHeaderState();
}

class _CnCalendarHeaderState extends State<CnCalendarHeader> {
  @override
  Widget build(BuildContext context) {
    final decoration = CnProvider.of(context).decoration;
    String title = '';
    switch (widget.selectedView) {
      case CnCalendarView.month:
        title = DateFormat('MMMM yyyy').format(widget.selectedDate);
        break;
      case CnCalendarView.week:
        title = "${DateFormat('MMMM').format(widget.selectedDate)}, KW ${widget.selectedDate.weekOfYear}";
        break;
      case CnCalendarView.day:
        // Format
        title = DateFormat('E dd.MM.yyyy').format(widget.selectedDate);
        break;
    }

    return Container(
      padding: EdgeInsets.only(left: decoration.horizontalHeaderPadding, right: decoration.horizontalHeaderPadding),
      decoration: BoxDecoration(color: decoration.headerBackgroundColor),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: widget.leadingWidget != null
                ? GestureDetector(
                    onTap: widget.onLeadingTap,
                    behavior: HitTestBehavior.opaque,
                    child: widget.leadingWidget!,
                  )
                : SizedBox.shrink(),
          ),
          SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: decoration.headerForegroundColor),
            onPressed: () {
              widget.onDateChanged(newSelectedDate(false), widget.selectedView);
            },
          ),
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: widget.onHeaderTap,
              behavior: HitTestBehavior.opaque,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: decoration.headerForegroundColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: decoration.headerForegroundColor),
            onPressed: () {
              widget.onDateChanged(newSelectedDate(true), widget.selectedView);
            },
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: CnCalendarViewPicker(onViewChanged: (view) => widget.onViewChanged?.call(widget.selectedDate, view)),
          ),
        ],
      ),
    );
  }

  DateTime newSelectedDate(bool add) {
    switch (widget.selectedView) {
      case CnCalendarView.month:
        return widget.selectedDate.addMonths(add ? 1 : -1).firstDayOfMonth;
      case CnCalendarView.week:
        return widget.selectedDate.addDays(add ? 7 : -7).firstDayOfWeek;
      case CnCalendarView.day:
        return widget.selectedDate.add(Duration(days: add ? 1 : -1));
    }
  }
}
