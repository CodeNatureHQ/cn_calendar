import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:flutter/material.dart';

class CnCalendarDayTimeline extends StatelessWidget {
  const CnCalendarDayTimeline({
    super.key,
    required this.hourHeight,
  });

  final double hourHeight;

  @override
  Widget build(BuildContext context) {
    int paintHours = 23;
    final decoration = CnProvider.of(context).decoration;
    return SizedBox(
      height: (paintHours + 4) * hourHeight,
      child: Stack(
        children: List.generate(
          paintHours,
          (index) {
            final hour = index + 1;
            return Positioned(
              top: index * hourHeight,
              left: 0,
              right: 0,
              child: Container(
                height: hourHeight,
                margin: const EdgeInsets.only(left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${hour.toString().padLeft(2, '0')}:00',
                      style: TextStyle(
                        color: decoration.timelineTextColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      height: 2,
                      color: decoration.timelineLinesColor,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
