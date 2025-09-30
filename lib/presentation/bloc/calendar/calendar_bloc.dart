import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/data/models/calendar_event.dart' as model;
import 'package:test_app/data/repositories/calendar_repository.dart';
import 'package:test_app/data/shared_prefs_service.dart';

import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarEventState> {
  final CalendarRepository calendarRepository;
  final SharedPrefsService _prefs = SharedPrefsService.instance;
  int? _currentYear;
  int? _currentMonth;

  CalendarBloc({required this.calendarRepository})
    : super(const CalendarInitial()) {
    on<AddCalendarEvent>(_addCalendarEvent);
    on<LoadCalendarEvents>(_loadCalendarEvents);
  }

  Future<void> _addCalendarEvent(
    AddCalendarEvent event,
    Emitter<CalendarEventState> emit,
  ) async {
    try {
      await calendarRepository.sendCalendarEvent(event: event.event);
      final dateKey = event.event.date.toIso8601String().substring(0, 10);
      await _prefs.addEvent(dateKey, event.event);

      final dates = await _prefs.getAllEventDateKeys();
      final bool withinCurrentMonth =
          _currentYear != null &&
          _currentMonth != null &&
          event.event.date.year == _currentYear &&
          event.event.date.month == _currentMonth;

      if (state is CalendarLoaded) {
        final currentState = state as CalendarLoaded;
        final updated = List<model.CalendarEvent>.from(currentState.events);
        if (withinCurrentMonth) {
          updated.add(event.event);
        }
        emit(CalendarLoaded(updated, eventDateKeys: dates));
      } else {
        emit(
          CalendarLoaded(
            withinCurrentMonth
                ? <model.CalendarEvent>[event.event]
                : <model.CalendarEvent>[],
            eventDateKeys: dates,
          ),
        );
      }
    } catch (e) {
      emit(const CalendarFailure('Не удалось добавить событие'));
    }
  }

  Future<void> _loadCalendarEvents(
    LoadCalendarEvents event,
    Emitter<CalendarEventState> emit,
  ) async {
    try {
      _currentYear = event.year;
      _currentMonth = event.month;
      await calendarRepository.getCalendarEvents(date: event.year.toString());
      final Set<String> markedDates = await _prefs.getAllEventDateKeys();

      final List<model.CalendarEvent> monthEvents = <model.CalendarEvent>[];
      final DateTime monthEnd = DateTime(event.year, event.month + 1, 0);

      for (int day = 1; day <= monthEnd.day; day++) {
        final DateTime d = DateTime(event.year, event.month, day);
        final String key = d.toIso8601String().substring(0, 10);
        final List<model.CalendarEvent> dayEvents = await _prefs
            .getEventsByDate(key);
        if (dayEvents.isNotEmpty) {
          monthEvents.addAll(dayEvents);
        }
      }

      emit(CalendarLoaded(monthEvents, eventDateKeys: markedDates));
    } catch (e) {
      emit(const CalendarFailure('Не удалось загрузить календарь'));
    }
  }
}
