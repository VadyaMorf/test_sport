import 'package:equatable/equatable.dart';
import 'package:test_app/data/models/calendar_event.dart' as model;

abstract class CalendarEventState extends Equatable {
  const CalendarEventState();

  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarEventState {
  const CalendarInitial();
}

class CalendarLoading extends CalendarEventState {
  const CalendarLoading();
}

class CalendarLoaded extends CalendarEventState {
  final List<model.CalendarEvent> events;
  final Set<String> eventDateKeys;

  const CalendarLoaded(this.events, {this.eventDateKeys = const <String>{}});

  @override
  List<Object?> get props => [events, eventDateKeys];
}

class CalendarFailure extends CalendarEventState {
  final String message;

  const CalendarFailure(this.message);

  @override
  List<Object?> get props => [message];
}
