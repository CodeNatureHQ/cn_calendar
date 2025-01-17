import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:flutter/material.dart';

class CnCalendarFullDayEntryCard extends StatelessWidget {
  const CnCalendarFullDayEntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.width,
  });

  final CnCalendarEntry entry;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
        entry.onTap?.call();
      },
      child: Container(
        width: width ?? double.infinity,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: entry.color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          entry.title,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}
