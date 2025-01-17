import 'package:cn_calendar/models/cn_decoration.dart';
import 'package:flutter/material.dart';

/// Provides the [CnDecoration] and the visibility of the different views to the calendar
class CnProvider extends InheritedWidget {
  final CnDecoration decoration;
  final bool showMonthView;
  final bool showWeekView;
  final bool showDayView;

  const CnProvider({
    super.key,
    required this.decoration,
    required this.showMonthView,
    required this.showWeekView,
    required this.showDayView,
    required super.child,
  });

  static CnProvider? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<CnProvider>();
  }

  static CnProvider of(BuildContext context) {
    final CnProvider? result = maybeOf(context);
    assert(result != null, 'No FrogColor found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}
