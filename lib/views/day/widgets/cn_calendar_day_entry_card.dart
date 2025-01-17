import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:flutter/material.dart';

class CnCalendarDayEntryCard extends StatelessWidget {
  const CnCalendarDayEntryCard({
    super.key,
    required this.entry,
    this.height = 20,
    this.onTap,
    this.width,
  });

  final CnCalendarEntry entry;
  final double height;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (entry.dateUntil.difference(entry.dateFrom).inMinutes.abs() >= 60) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          width: width ?? 150,
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: entry.color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.imageUrl != null)
                Container(
                  constraints: BoxConstraints(maxWidth: 64, maxHeight: 64),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(entry.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(width: 8.0),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${entry.dateFrom.timeOfDay.format(context)} - ${entry.dateUntil.timeOfDay.format(context)} Uhr',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width ?? 150,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: entry.color,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
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
