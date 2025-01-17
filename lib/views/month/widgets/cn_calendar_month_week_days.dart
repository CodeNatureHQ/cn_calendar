import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CnCalendarMonthWeekDays extends StatelessWidget {
  const CnCalendarMonthWeekDays({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a list of weekays starting from Monday
    final weekdays = DateFormat().dateSymbols.STANDALONESHORTWEEKDAYS;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              7,
              (index) {
                final weekdayIndex = (index + 1) % 7; // Ensures we start from Monday
                return Expanded(
                  child: Text(
                    weekdays[weekdayIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
