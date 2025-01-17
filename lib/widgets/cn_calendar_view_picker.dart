import 'package:cn_calendar/models/cn_calendar_view.dart';
import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:flutter/material.dart';

/// A widget that allows the user to select the view of the calendar
class CnCalendarViewPicker extends StatelessWidget {
  const CnCalendarViewPicker({
    super.key,
    required this.onViewChanged,
  });

  /// Callback for view changes in the calendar [CnCalendarView.month], [CnCalendarView.week], [CnCalendarView.day]
  final Function(CnCalendarView selectedView) onViewChanged;

  @override
  Widget build(BuildContext context) {
    final cnProvider = CnProvider.of(context);
    return PopupMenuButton<CnCalendarView>(
      icon: Icon(
        cnProvider.decoration.headerSelectViewIcon,
        color: cnProvider.decoration.headerSelectViewIconColor,
      ),
      onSelected: onViewChanged,
      itemBuilder: (context) {
        return [
          if (cnProvider.showDayView)
            PopupMenuItem(
              value: CnCalendarView.day,
              child: Text('Day'),
            ),
          if (cnProvider.showWeekView)
            PopupMenuItem(
              value: CnCalendarView.week,
              child: Text('Week'),
            ),
          if (cnProvider.showMonthView)
            PopupMenuItem(
              value: CnCalendarView.month,
              child: Text('Month'),
            ),
        ];
      },
    );
  }
}
