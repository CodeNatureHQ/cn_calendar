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
    final bool isLongEvent = entry.dateUntil.difference(entry.dateFrom).inMinutes.abs() >= 60;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width ?? 150,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: entry.color,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLongEvent ? _buildLongEventContent(context) : _buildShortEventContent(context),
      ),
    );
  }

  /// Content for events longer than 1 hour
  Widget _buildLongEventContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entry.imageUrl != null)
          Container(
            constraints: const BoxConstraints(maxWidth: 64, maxHeight: 64),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(entry.imageUrl!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with flexible wrapping
              Flexible(
                child: Text(
                  entry.title,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Time with flexible wrapping
              Flexible(
                child: Text(
                  '${entry.dateFrom.timeOfDay.format(context)} - ${entry.dateUntil.timeOfDay.format(context)} Uhr',
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Content for events shorter than 1 hour
  Widget _buildShortEventContent(BuildContext context) {
    return Text(
      entry.title,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
    );
  }
}
