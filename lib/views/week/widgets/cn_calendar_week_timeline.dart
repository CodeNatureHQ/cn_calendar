import 'package:cn_calendar/provider/cn_provider.dart';
import 'package:flutter/material.dart';

class CnCalendarWeekTimeline extends StatelessWidget {
  const CnCalendarWeekTimeline({
    super.key,
    required this.hourHeight,
  });

  final double hourHeight;

  @override
  Widget build(BuildContext context) {
    final decoration = CnProvider.of(context).decoration;
    int paintHours = 23;
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
              child: SizedBox(
                height: hourHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${hour.toString().padLeft(2, '0')}:00',
                      style: TextStyle(
                        color: decoration.timelineTextColor,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      height: 0.1,
                      color: Colors.grey,
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
