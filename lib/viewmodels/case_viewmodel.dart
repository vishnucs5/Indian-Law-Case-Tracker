import 'package:flutter/foundation.dart';
import '../models/legal_case.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';

class CaseViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final SyncService _syncService = SyncService();

  List<LegalCase> _allCases = [];
  List<LegalCase> _upcomingCases = [];
  List<LegalCase> _pendingOutcomes = [];
  List<LegalCase> _todaysCases = [];
  List<LegalCase> _tomorrowsCases = [];
  int _activeCasesCount = 0;
  int _upcomingHearingsCount = 0;

  List<LegalCase> get allCases => _allCases;
  List<LegalCase> get upcomingCases => _upcomingCases;
  List<LegalCase> get pendingOutcomes => _pendingOutcomes;
  List<LegalCase> get todaysCases => _todaysCases;
  List<LegalCase> get tomorrowsCases => _tomorrowsCases;
  int get activeCasesCount => _activeCasesCount;
  int get upcomingHearingsCount => _upcomingHearingsCount;

  SyncStatus get syncStatus => _syncService.status;
  String? get syncError => _syncService.lastError;
  DateTime? get lastSyncedAt => _syncService.lastSyncedAt;
  bool get isSignedIn => _syncService.auth.currentUser != null;

  int _dayBeforeHour = 9;
  int _dayOfHour = 8;

  int get dayBeforeHour => _dayBeforeHour;
  int get dayOfHour => _dayOfHour;

  void setReminderTimes({required int dayBefore, required int dayOf}) {
    _dayBeforeHour = dayBefore;
    _dayOfHour = dayOf;
    notifyListeners();
  }

  Future<void> initialize() async {
    await _syncService.initialize();
    _syncService.addListener(_onSyncChanged);
    
    // Auto sign-in anonymously if not already signed in
    if (_syncService.auth.currentUser == null) {
      await _syncService.signInAnonymously();
    }
    
    await _startListening();
  }

  void _onSyncChanged() {
    notifyListeners();
  }

  Future<void> _startListening() async {
    _syncService.watchCases().listen((cases) {
      _allCases = cases;
      _loadUpcomingCases();
      _loadPendingOutcomes();
      _loadTodayAndTomorrow();
      _calculateAnalytics();
      notifyListeners();
    });
  }

  Future<void> refresh() async {
    if (_syncService.auth.currentUser != null) {
      await _syncService.manualSync();
    } else {
      await _loadAllCases();
      _loadUpcomingCases();
      _loadPendingOutcomes();
      _loadTodayAndTomorrow();
      _calculateAnalytics();
      notifyListeners();
    }
  }

  Future<void> _loadAllCases() async {
    _allCases = await _databaseService.getAllCases();
  }

  Future<void> _loadUpcomingCases() async {
    _upcomingCases = _allCases.where((c) => c.status == 'upcoming').toList();
  }

  Future<void> _loadPendingOutcomes() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    _pendingOutcomes = _allCases.where((c) =>
        c.status == 'upcoming' && c.caseDate.isBefore(startOfToday)).toList();
  }

  void _loadTodayAndTomorrow() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfterTomorrow = today.add(const Duration(days: 2));

    _todaysCases = _allCases.where((c) =>
        c.status == 'upcoming' &&
        !c.caseDate.isBefore(today) &&
        c.caseDate.isBefore(tomorrow)).toList();

    _tomorrowsCases = _allCases.where((c) =>
        c.status == 'upcoming' &&
        !c.caseDate.isBefore(tomorrow) &&
        c.caseDate.isBefore(dayAfterTomorrow)).toList();
  }

  Future<void> addCase({
    required String caseNumber,
    required String caseName,
    required String customerName,
    required DateTime caseDate,
    String? notes,
  }) async {
    final legalCase = LegalCase(
      caseNumber: caseNumber,
      caseName: caseName,
      customerName: customerName,
      caseDate: caseDate,
      notes: notes,
      userId: _syncService.auth.currentUser?.uid ?? '',
    );

    await _databaseService.insertCase(legalCase);
    await _notificationService.scheduleReminders(
      legalCase,
      dayBeforeHour: _dayBeforeHour,
      dayOfHour: _dayOfHour,
    );

    if (_syncService.auth.currentUser != null) {
      await _syncService.firestore.uploadCase(legalCase);
    }

    await refresh();
  }

  Future<void> updateCase(
    LegalCase legalCase, {
    required String caseNumber,
    required String caseName,
    required String customerName,
    required DateTime caseDate,
    String? notes,
  }) async {
    if (legalCase.caseDate != caseDate) {
      final event = RescheduleEvent(
        caseId: legalCase.id,
        oldDate: legalCase.caseDate,
        newDate: caseDate,
        userId: _syncService.auth.currentUser?.uid ?? '',
      );
      await _databaseService.addRescheduleEvent(event);
      legalCase.rescheduleHistory.add(event);
    }

    legalCase.caseNumber = caseNumber;
    legalCase.caseName = caseName;
    legalCase.customerName = customerName;
    legalCase.caseDate = caseDate;
    legalCase.notes = notes;
    legalCase.updatedAt = DateTime.now();

    await _databaseService.updateCase(legalCase);
    await _notificationService.scheduleReminders(
      legalCase,
      dayBeforeHour: _dayBeforeHour,
      dayOfHour: _dayOfHour,
    );

    if (_syncService.auth.currentUser != null) {
      await _syncService.firestore.updateCase(legalCase);
    }

    await refresh();
  }

  Future<void> rescheduleCase(LegalCase legalCase, DateTime newDate, {String? reason}) async {
    final event = RescheduleEvent(
      caseId: legalCase.id,
      oldDate: legalCase.caseDate,
      newDate: newDate,
      reason: reason,
      userId: _syncService.auth.currentUser?.uid ?? '',
    );

    await _databaseService.addRescheduleEvent(event);
    legalCase.rescheduleHistory.add(event);
    legalCase.caseDate = newDate;
    legalCase.status = 'upcoming';
    legalCase.updatedAt = DateTime.now();

    await _databaseService.updateCase(legalCase);
    await _notificationService.cancelReminders(legalCase.id);
    await _notificationService.scheduleReminders(
      legalCase,
      dayBeforeHour: _dayBeforeHour,
      dayOfHour: _dayOfHour,
    );

    if (_syncService.auth.currentUser != null) {
      await _syncService.firestore.updateCase(legalCase);
      await _syncService.firestore.uploadEvent(legalCase.id, event);
    }

    await refresh();
  }

  Future<void> markCompleted(LegalCase legalCase) async {
    legalCase.status = 'completed';
    legalCase.updatedAt = DateTime.now();
    await _databaseService.updateCase(legalCase);
    await _notificationService.cancelReminders(legalCase.id);

    if (_syncService.auth.currentUser != null) {
      await _syncService.firestore.updateCase(legalCase);
    }

    await refresh();
  }

  Future<void> deleteCase(LegalCase legalCase) async {
    await _notificationService.cancelReminders(legalCase.id);
    await _databaseService.deleteCase(legalCase.id);

    if (_syncService.auth.currentUser != null) {
      await _syncService.firestore.deleteCase(legalCase.id);
    }

    await refresh();
  }

  void _calculateAnalytics() {
    _activeCasesCount = _allCases.where((c) => c.status == 'upcoming').length;
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    _upcomingHearingsCount = _allCases.where((c) =>
        c.status == 'upcoming' &&
        !c.caseDate.isBefore(now) &&
        c.caseDate.isBefore(weekFromNow)).length;
  }

  Future<void> rescheduleAllNotifications() async {
    for (final caseItem in _upcomingCases) {
      await _notificationService.scheduleReminders(
        caseItem,
        dayBeforeHour: _dayBeforeHour,
        dayOfHour: _dayOfHour,
      );
    }
  }

  Future<void> signInAnonymously() async {
    await _syncService.signInAnonymously();
  }

  Future<void> signOut() async {
    await _syncService.signOut();
    await _loadAllCases();
    _loadUpcomingCases();
    _loadPendingOutcomes();
    _loadTodayAndTomorrow();
    _calculateAnalytics();
    notifyListeners();
  }

  @override
  void dispose() {
    _syncService.removeListener(_onSyncChanged);
    super.dispose();
  }
}