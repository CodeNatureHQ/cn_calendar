import 'package:cn_calendar/extensions/date.extension.dart';
import 'package:cn_calendar/models/cn_calendar_entry.dart';
import 'package:flutter/material.dart';

class CnCalendarDayEntryCard extends StatelessWidget {
  const CnCalendarDayEntryCard({super.key, required this.entry, this.height = 20, this.onTap, this.width});

  final CnCalendarEntry entry;
  final double height;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final bool isLongEvent = entry.dateUntil.difference(entry.dateFrom).inMinutes.abs() >= 60;
    // Show text for even very small entries based on height
    final bool shouldShowText = height >= 12; // Show text if height is at least 12px
    final EdgeInsets padding = height < 20
        ? const EdgeInsets.all(2) // Minimal padding for very small entries
        : const EdgeInsets.all(6); // Normal padding for larger entries

    return GestureDetector(
      onTapUp: (_) => onTap?.call(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height, // Maintain exact time-based height
        width: width ?? 150,
        clipBehavior: Clip.none, // Allow text to overflow for visibility
        decoration: BoxDecoration(
          color: entry.color,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4, offset: const Offset(0, 4)),
          ],
        ),
        child: shouldShowText
            ? Padding(
                padding: padding, // Use dynamic padding based on height
                child: Align(
                  alignment: Alignment.centerLeft, // Left align the content
                  child: isLongEvent ? _buildLongEventContent(context) : _buildShortEventContent(context),
                ),
              )
            : const SizedBox.shrink(), // No content for very short entries
      ),
    );
  }

  /// Content for events longer than 1 hour
  Widget _buildLongEventContent(BuildContext context) {
    // For very small entries, show simplified content with optimal font size
    if (height < 25) {
      return Text(
        entry.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: TextAlign.left, // Left align the text
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: _calculateOptimalFontSize(height),
          height: 1.0, // Tight line height for maximum space usage
        ),
      );
    }

    // For medium-sized entries, show title and time but smaller
    if (height < 50) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Left align children
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            entry.title,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: _calculateOptimalFontSize(height),
              height: 1.0,
            ),
          ),
          if (height >= 35) // Only show time if there's enough space
            Text(
              '${entry.dateFrom.timeOfDay.format(context)} - ${entry.dateUntil.timeOfDay.format(context)}',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.white, fontSize: _calculateOptimalFontSize(height) - 2, height: 1.0),
            ),
        ],
      );
    }

    // Full content for larger entries - use regular layout without Flexible widgets
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Center align content vertically
      children: [
        if (entry.imageUrl != null)
          Container(
            constraints: const BoxConstraints(maxWidth: 64, maxHeight: 64),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(image: NetworkImage(entry.imageUrl!), fit: BoxFit.cover),
            ),
          ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title without Flexible
              Text(
                entry.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              // Time without Flexible
              Text(
                '${entry.dateFrom.timeOfDay.format(context)} - ${entry.dateUntil.timeOfDay.format(context)} Uhr',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Content for events shorter than 1 hour
  Widget _buildShortEventContent(BuildContext context) {
    // Calculate appropriate font size based on available height
    double fontSize = _calculateOptimalFontSize(height);

    return Text(
      entry.title,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      textAlign: TextAlign.left, // Left align the text
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.0, // Tight line height for maximum space usage
      ),
    );
  }

  /// Calculate optimal font size based on container height
  double _calculateOptimalFontSize(double containerHeight) {
    if (containerHeight >= 40) return 14.0; // Normal size for tall entries
    if (containerHeight >= 25) return 12.0; // Medium size
    if (containerHeight >= 20) return 10.0; // Small size
    if (containerHeight >= 15) return 8.0; // Very small size
    return 6.0; // Extremely small but still readable for very short entries
  }
}
