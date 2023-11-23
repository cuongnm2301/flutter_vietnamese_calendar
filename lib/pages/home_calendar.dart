import 'package:flutter/material.dart';
import 'package:vical/calendar_utils.dart';
import 'package:vical/utils.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeCalendar extends StatefulWidget {
  const HomeCalendar({super.key});

  @override
  MainCalendar createState() => MainCalendar();
}

class MainCalendar extends State<HomeCalendar> {
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
                    type: DateType.defaultDate,
                  ),
                  outsideBuilder: (context, day, focusedDay) =>
                      DateBuilderWidget(
                    context: context,
                    day: day,
                    focusedDay: focusedDay,
                    type: DateType.outSideDate,
                  ),
                  todayBuilder: (context, day, focusedDay) => DateBuilderWidget(
                    context: context,
                    day: day,
                    focusedDay: focusedDay,
                    type: DateType.todayDate,
                  ),
                ),
                calendarStyle: CalendarStyle(
                    tableBorder:
                        TableBorder.all(width: 1, color: Colors.pink.shade300),
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

enum DateType {
  defaultDate,
  outSideDate,
  todayDate,
}

Map<DateType, Color> dateTypeColorMap = {
  DateType.defaultDate: Colors.pink.shade300,
  DateType.outSideDate: Colors.grey,
  DateType.todayDate: Colors.black,
};

class DateBuilderWidget extends StatelessWidget {
  final BuildContext? context;
  final DateTime day;
  final DateTime focusedDay;
  final DateType type;

  // Constructor
  const DateBuilderWidget({
    Key? key,
    required this.context,
    required this.day,
    required this.focusedDay,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<int> lunarDay =
        CalendarUtils().convertSolar2Lunar(day.day, day.month, day.year);
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.only(top: 6, left: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(color: dateTypeColorMap[type], fontSize: 16),
          ),
          Text(
            '${lunarDay[0]}/${lunarDay[1]}',
            style: TextStyle(color: dateTypeColorMap[type], fontSize: 14),
          )
        ],
      ),
    );
  }
}
