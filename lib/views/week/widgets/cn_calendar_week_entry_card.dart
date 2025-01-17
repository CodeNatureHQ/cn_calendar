import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:flutter/material.dart';

class CnCalendarWeekEntryCard extends StatelessWidget {
  const CnCalendarWeekEntryCard({
    super.key,
    required this.entry,
    this.height = 20,
    this.onTap,
  });

  final CnCalendarEntry entry;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
        entry.onTap?.call();
      },
      child: Container(
        height: height,
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: entry.color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          entry.title,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}
