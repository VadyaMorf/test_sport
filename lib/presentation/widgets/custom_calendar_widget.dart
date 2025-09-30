import 'package:flutter/material.dart';

class CustomCalendarWidget extends StatefulWidget {
  const CustomCalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onClose,
    this.markedDates = const <String>{},
    this.onMonthChanged,
    this.onDayTapped,
  });

  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final VoidCallback onClose;
  final Set<String> markedDates;
  final void Function(int year, int month)? onMonthChanged;
  final void Function(DateTime date, bool hasEvent)? onDayTapped;

  @override
  State<CustomCalendarWidget> createState() => CustomCalendarWidgetState();
}

class CustomCalendarWidgetState extends State<CustomCalendarWidget> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
    _selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(children: [_buildHeader(), _buildCalendarGrid()]),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            _getMonthYearString(),
            style: const TextStyle(
              fontFamily: 'SF UI Display',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          Row(
            children: <Widget>[
              _RoundedIconButton(
                icon: Icons.chevron_left,
                onTap: _previousMonth,
              ),
              const SizedBox(width: 8),
              _RoundedIconButton(icon: Icons.chevron_right, onTap: _nextMonth),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final firstWeekday = firstDayOfMonth.weekday;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        children: <Widget>[
          _buildWeekdayHeader(),
          const SizedBox(height: 12),
          _buildDaysGrid(daysInMonth, firstWeekday),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const List<String> weekdays = <String>[
      'ПН',
      'ВТ',
      'СР',
      'ЧТ',
      'ПТ',
      'СБ',
      'ВС',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weekdays
          .map(
            (String day) => SizedBox(
              width: 36,
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'SF UI Display',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDaysGrid(int daysInMonth, int firstWeekday) {
    final List<Widget> tiles = <Widget>[];

    for (int i = 1; i < firstWeekday; i++) {
      tiles.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime date = DateTime(
        _currentMonth.year,
        _currentMonth.month,
        day,
      );
      final String dateKey = date.toIso8601String().substring(0, 10);
      final bool isSelected =
          date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;
      final bool isToday =
          date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;
      final bool hasEvent = widget.markedDates.contains(dateKey);

      tiles.add(
        GestureDetector(
          onTap: () {
            if (hasEvent) {
              widget.onDayTapped?.call(date, hasEvent);
              return;
            }
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFF4D5A)
                  : (hasEvent ? Colors.blue.shade100 : Colors.transparent),
              borderRadius: BorderRadius.circular(20),
              border: isToday && !isSelected
                  ? Border.all(color: Colors.white.withOpacity(0.6), width: 1)
                  : null,
            ),
            child: Text(
              day.toString(),
              style: TextStyle(
                fontFamily: 'SF UI Display',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isSelected
                    ? Colors.white
                    : (hasEvent ? Colors.blue.shade800 : Colors.black),
              ),
            ),
          ),
        ),
      );
    }

    while (tiles.length % 7 != 0) {
      tiles.add(const SizedBox.shrink());
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1,
      children: tiles,
    );
  }

  String _getMonthYearString() {
    const List<String> months = <String>[
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];
    return '${months[_currentMonth.month - 1]} ${_currentMonth.year}';
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    widget.onMonthChanged?.call(_currentMonth.year, _currentMonth.month);
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    widget.onMonthChanged?.call(_currentMonth.year, _currentMonth.month);
  }
}

class _RoundedIconButton extends StatelessWidget {
  const _RoundedIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 24, color: Colors.black),
    );
  }
}
