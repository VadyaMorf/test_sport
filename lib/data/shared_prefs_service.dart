import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/data/models/calendar_event.dart' as model;
import 'package:test_app/data/models/user_model.dart';

class SharedPrefsService {
  static const String _userKey = 'auth_user';
  static const String _calendarKeyPrefix = 'calendar_events_';

  SharedPrefsService._();

  static final SharedPrefsService instance = SharedPrefsService._();

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  String _eventsKeyForDate(String dateIso) => '$_calendarKeyPrefix$dateIso';

  Future<List<model.CalendarEvent>> getEventsByDate(String dateIso) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_eventsKeyForDate(dateIso));
    if (raw == null) return <model.CalendarEvent>[];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map((e) => model.CalendarEvent.fromJson(e)).toList();
    } catch (_) {
      return <model.CalendarEvent>[];
    }
  }

  Future<void> addEvent(String dateIso, model.CalendarEvent event) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _eventsKeyForDate(dateIso);
    final current = await getEventsByDate(dateIso);
    current.add(event);
    final encoded = jsonEncode(current.map((e) => e.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  Future<Set<String>> getAllEventDateKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Set<String> result = <String>{};
    for (final String key in keys) {
      if (key.startsWith(_calendarKeyPrefix)) {
        final raw = prefs.getString(key);
        if (raw == null) continue;
        try {
          final list = jsonDecode(raw) as List<dynamic>;
          if (list.isNotEmpty) {
            final dateIso = key.replaceFirst(_calendarKeyPrefix, '');
            result.add(dateIso);
          }
        } catch (_) {}
      }
    }
    return result;
  }
}
