import 'package:equatable/equatable.dart';
import 'package:test_app/data/models/calendar_event.dart' as model;

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class LoadCalendarEvents extends CalendarEvent {
  final int year;
  final int month;

  const LoadCalendarEvents({required this.year, required this.month});

  @override
  List<Object?> get props => [year, month];
}

class AddCalendarEvent extends CalendarEvent {
  final model.CalendarEvent event;

  const AddCalendarEvent({required this.event});

  @override
  List<Object?> get props => [event];
}
