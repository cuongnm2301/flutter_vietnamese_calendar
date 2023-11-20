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
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
            SizedBox(
              child: TableCalendar(
                rowHeight: 100,
                daysOfWeekHeight: 50,
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
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) =>
                      DateBuilderWidget(
                    context: context,
                    day: day,
                    focusedDay: focusedDay,
                  ),
                  outsideBuilder: (context, day, focusedDay) =>
                      DateBuilderWidget(
                    context: context,
                    day: day,
                    focusedDay: focusedDay,
                  ),
                  // todayBuilder: (context, day, focusedDay) =>
                  //     DateBuilderWidget(
                  //       context: context,
                  //       day: day,
                  //       focusedDay: focusedDay,
                  //     ),
                  //     dowBuilder: (context, date) {
                  //   String formattedDate = DateFormat('E', 'vi_VN').format(date);
                  //   return Container(
                  //     margin: const EdgeInsets.all(
                  //         0.5), // Adjust margin for line thickness
                  //     decoration: const BoxDecoration(
                  //       border: Border(
                  //           right: BorderSide(
                  //               width: 1,
                  //               color: Colors.grey)), // Line color and style
                  //     ),
                  //     child: Center(
                  //       child: Text(
                  //         formattedDate,
                  //         style: const TextStyle().copyWith(fontSize: 16.0),
                  //       ),
                  //     ),
                  //   );
                  // }
                  // Repeat similar builder for outsideBuilder, holidayBuilder, etc., if needed
                ),
                calendarStyle: CalendarStyle(
                    tableBorder: TableBorder.all(width: 1, color: Colors.grey),
                    tablePadding: const EdgeInsets.only(left: 12, right: 12),
                    cellMargin: const EdgeInsets.all(0)),
              ),
            )
          ]),
        ));
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

class DateBuilderWidget extends StatelessWidget {
  final BuildContext? context;
  final DateTime day;
  final DateTime focusedDay;

  // Constructor
  const DateBuilderWidget({
    Key? key,
    required this.context,
    required this.day,
    required this.focusedDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '${day.day}',
      ),
    );
  }
}
