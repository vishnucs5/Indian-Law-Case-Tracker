import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/legal_case.dart';

class DatabaseService {
  static const String _casesKey = 'casetrack_cases';
  static const String _eventsKey = 'casetrack_events';

  Future<void> insertCase(LegalCase legalCase) async {
    final prefs = await SharedPreferences.getInstance();
    final cases = await getAllCases();
    cases.add(legalCase);
    final jsonList = cases.map((c) => c.toMap()).toList();
    await prefs.setString(_casesKey, jsonEncode(jsonList));
  }

  Future<void> updateCase(LegalCase legalCase) async {
    final prefs = await SharedPreferences.getInstance();
    final cases = await getAllCases();
    final index = cases.indexWhere((c) => c.id == legalCase.id);
    if (index != -1) {
      cases[index] = legalCase;
      final jsonList = cases.map((c) => c.toMap()).toList();
      await prefs.setString(_casesKey, jsonEncode(jsonList));
    }
  }

  Future<void> deleteCase(String caseId) async {
    final prefs = await SharedPreferences.getInstance();
    final cases = await getAllCases();
    cases.removeWhere((c) => c.id == caseId);
    final jsonList = cases.map((c) => c.toMap()).toList();
    await prefs.setString(_casesKey, jsonEncode(jsonList));

    // Also remove associated events
    final events = await _getAllEvents();
    events.removeWhere((e) => e.caseId == caseId);
    final eventsJson = events.map((e) => e.toMap()).toList();
    await prefs.setString(_eventsKey, jsonEncode(eventsJson));
  }

  Future<List<LegalCase>> getAllCases() async {
    final prefs = await SharedPreferences.getInstance();
    final casesJson = prefs.getString(_casesKey);
    if (casesJson == null) return [];

    final List<dynamic> jsonList = jsonDecode(casesJson);
    final cases = jsonList.map((m) => LegalCase.fromMap(m)).toList();

    // Load reschedule events for each case
    final events = await _getAllEvents();
    for (final c in cases) {
      c.rescheduleHistory = events.where((e) => e.caseId == c.id).toList();
    }

    cases.sort((a, b) => a.caseDate.compareTo(b.caseDate));
    return cases;
  }

  Future<List<LegalCase>> getUpcomingCases() async {
    final cases = await getAllCases();
    return cases.where((c) => c.status == 'upcoming').toList();
  }

  Future<List<LegalCase>> getPendingOutcomes() async {
    final cases = await getAllCases();
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    return cases.where((c) =>
        c.status == 'upcoming' && c.caseDate.isBefore(startOfToday)).toList();
  }

  Future<void> addRescheduleEvent(RescheduleEvent event) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await _getAllEvents();
    events.add(event);
    final eventsJson = events.map((e) => e.toMap()).toList();
    await prefs.setString(_eventsKey, jsonEncode(eventsJson));
  }

  Future<List<RescheduleEvent>> _getAllEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString(_eventsKey);
    if (eventsJson == null) return [];
    final List<dynamic> jsonList = jsonDecode(eventsJson);
    return jsonList.map((m) => RescheduleEvent.fromMap(m)).toList();
  }
}
