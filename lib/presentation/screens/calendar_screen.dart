import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/data/models/calendar_event.dart' as model;
import 'package:test_app/presentation/bloc/calendar/calendar_bloc.dart';
import 'package:test_app/presentation/bloc/calendar/calendar_event.dart';
import 'package:test_app/presentation/bloc/calendar/calendar_state.dart';
import 'package:test_app/presentation/widgets/custom_calendar_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  DateTime _selected = DateTime.now();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late final AnimationController _topBarController;
  late final AnimationController _calendarController;
  late final Animation<double> _topBarFade;
  late final Animation<Offset> _topBarSlide;
  late final Animation<double> _calendarFade;
  late final Animation<Offset> _calendarSlide;
  @override
  void initState() {
    super.initState();
    _topBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _calendarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _topBarFade = CurvedAnimation(
      parent: _topBarController,
      curve: Curves.easeOut,
    );
    _topBarSlide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _topBarController,
            curve: Curves.easeOutCubic,
          ),
        );

    _calendarFade = CurvedAnimation(
      parent: _calendarController,
      curve: Curves.easeOut,
    );
    _calendarSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _calendarController,
            curve: Curves.easeOutCubic,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      context.read<CalendarBloc>().add(
        LoadCalendarEvents(year: now.year, month: now.month),
      );
      _topBarController.forward();
      _calendarController.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _topBarController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarEventState>(
      builder: (context, state) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.grey.shade200, Colors.grey.shade600],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FadeTransition(
                      opacity: _topBarFade,
                      child: SlideTransition(
                        position: _topBarSlide,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Создать событие",
                              style: TextStyle(fontSize: 20),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                openModal(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                iconColor: Colors.black,
                              ),
                              child: Text(
                                "+",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _calendarFade,
                      child: SlideTransition(
                        position: _calendarSlide,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: BlocBuilder<CalendarBloc, CalendarEventState>(
                            builder: (context, state) {
                              final Set<String> marked = state is CalendarLoaded
                                  ? state.eventDateKeys
                                  : const <String>{};
                              return CustomCalendarWidget(
                                selectedDate: _selected,
                                onDateSelected: (DateTime d) {
                                  // setState(() => _selected = d);
                                },
                                onClose: () {},
                                markedDates: marked,
                                onMonthChanged: (int year, int month) {
                                  context.read<CalendarBloc>().add(
                                    LoadCalendarEvents(
                                      year: year,
                                      month: month,
                                    ),
                                  );
                                },
                                onDayTapped: (DateTime date, bool hasEvent) {
                                  if (hasEvent) {
                                    _openEventsListModal(context, date);
                                  } else {
                                    return;
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> openModal(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        DateTime selectedDate = _selected;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: StatefulBuilder(
              builder:
                  (
                    BuildContext context,
                    void Function(void Function()) setModalState,
                  ) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Новое событие',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Название события',
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Описание',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final DateTime now = DateTime.now();
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(now.year - 5),
                                    lastDate: DateTime(now.year + 5),
                                  );
                                  if (picked != null) {
                                    setModalState(() {
                                      selectedDate = picked;
                                    });
                                  }
                                },
                                child: const Text('Выбрать дату'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final String title = _titleController.text
                                    .trim();
                                final String description =
                                    _descriptionController.text.trim();
                                if (title.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Введите название события'),
                                    ),
                                  );
                                  return;
                                }

                                final event = model.CalendarEvent(
                                  name: title,
                                  date: selectedDate,
                                  description: description,
                                );

                                context.read<CalendarBloc>().add(
                                  AddCalendarEvent(event: event),
                                );

                                setState(() {
                                  _selected = selectedDate;
                                });

                                _titleController.clear();
                                _descriptionController.clear();
                                Navigator.of(context).pop();
                              },
                              child: const Text('Сохранить'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
            ),
          ),
        );
      },
    );
  }

  void _openEventsListModal(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BlocBuilder<CalendarBloc, CalendarEventState>(
                builder: (context, state) {
                  if (state is CalendarLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is CalendarLoaded) {
                    final List<model.CalendarEvent> events = state.events;
                    if (events.isEmpty) {
                      return const Text('Событий нет');
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'События за ${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final String selectedKey = date
                                  .toIso8601String()
                                  .substring(0, 10);
                              final List<model.CalendarEvent> filtered = events
                                  .where(
                                    (e) =>
                                        e.date.toIso8601String().substring(
                                          0,
                                          10,
                                        ) ==
                                        selectedKey,
                                  )
                                  .toList();
                              if (filtered.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              final model.CalendarEvent e = filtered[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Row(
                                  children: [
                                    Text("Название события:"),
                                    SizedBox(width: 2),
                                    Text(e.name),
                                  ],
                                ),
                                subtitle: Row(
                                  children: [
                                    Text("Описание события:"),
                                    SizedBox(width: 2),
                                    Text(e.description),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const Divider(height: 16),
                            itemCount: events
                                .where(
                                  (e) =>
                                      e.date.toIso8601String().substring(
                                        0,
                                        10,
                                      ) ==
                                      date.toIso8601String().substring(0, 10),
                                )
                                .length,
                          ),
                        ),
                      ],
                    );
                  }
                  if (state is CalendarFailure) {
                    return Text(state.message);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
