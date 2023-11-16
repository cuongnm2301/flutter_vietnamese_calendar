// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_vietnamese_calendar/utils.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MainScreen()));
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  MainCalendar createState() => MainCalendar();
}

class MainCalendar extends State<HomePage> {
  late PageController _pageController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<DateTime>(
          valueListenable: _focusedDay,
          builder: (context, value, _) {
            return MonthDisplayWidget(
              day: value,
              onPreviousMonth: () => {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                )
              },
              onNextMonth: () => {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                )
              },
            );
          },
        ),
      ),
      body: TableCalendar(
        firstDay: kFirstDay,
        lastDay: kLastDay,
        focusedDay: _focusedDay.value,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onCalendarCreated: (controller) => _pageController = controller,
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            // Call `setState()` when updating the selected day
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay.value = focusedDay;
            });
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            // Call `setState()` when updating calendar format
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay.value = focusedDay;
        },
        locale: 'vi_VN',
        headerVisible: false,
        startingDayOfWeek: StartingDayOfWeek.monday,
      ),
    );
  }
}

class MonthDisplayWidget extends StatelessWidget {
  final DateTime? day;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  // Constructor
  const MonthDisplayWidget({
    Key? key,
    required this.day,
    required this.onPreviousMonth,
    required this.onNextMonth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool format = day!.year == DateTime.now().year;
    String displayMonth = format
        ? DateFormat.MMMM('vi_VN').format(day!)
        : DateFormat.yMMM('vi_VN').format(day!);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: onPreviousMonth,
        ),
        Text(
          displayMonth,
          style: const TextStyle(fontSize: 24),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: onNextMonth,
        ),
      ],
    );
  }
}
