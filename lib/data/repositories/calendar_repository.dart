import 'package:test_app/data/dio_client.dart';
import 'package:test_app/data/models/calendar_event.dart';

class CalendarRepository {
  final DioClient _dioClient = DioClient(baseUrl: 'https://url');
  Future<List<CalendarEvent>> getCalendarEvents({required String date}) async {
    try {
      final response = await _dioClient.executeQuery(
        resourceURL: '/calendarEvents',
        method: 'GET',
      );
      if (response?.statusCode == 200) {
        return response?.data.map((e) => CalendarEvent.fromJson(e)).toList() ??
            [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> sendCalendarEvent({required CalendarEvent event}) async {
    try {
      await _dioClient.executeQuery(
        resourceURL: '/calendarEvents',
        method: 'POST',
        body: event.toJson(),
      );
    } catch (e) {}
  }
}
