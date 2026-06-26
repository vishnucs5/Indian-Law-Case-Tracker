import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/legal_case.dart';
import 'database_service.dart';
import 'firestore_service.dart';
import 'auth_service.dart';

enum SyncStatus { synced, syncing, offline, error }

class SyncService extends ChangeNotifier {
  final DatabaseService _localDb;
  final FirestoreService _firestore;
  final AuthService _auth;

  SyncService({
    DatabaseService? localDb,
    FirestoreService? firestore,
    AuthService? auth,
  })  : _localDb = localDb ?? DatabaseService(),
        _firestore = firestore ?? FirestoreService(),
        _auth = auth ?? AuthService();

  AuthService get auth => _auth;
  FirestoreService get firestore => _firestore;

  SyncStatus _status = SyncStatus.offline;
  String? _lastError;
  DateTime? _lastSyncedAt;

  SyncStatus get status => _status;
  String? get lastError => _lastError;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  bool _isInitialized = false;
  bool _isSyncing = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _auth.authStateChanges.listen(_onAuthStateChanged);

    final user = _auth.currentUser;
    if (user != null) {
      await _startSync();
    }
    _isInitialized = true;
  }

  void _onAuthStateChanged(user) async {
    if (user != null) {
      await _startSync();
    } else {
      _stopSync();
    }
  }

  Future<void> _startSync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _setStatus(SyncStatus.syncing);

    try {
      await _migrateIfNeeded();
      _setStatus(SyncStatus.synced);
      _lastSyncedAt = DateTime.now();
      _lastError = null;
    } catch (e) {
      _setStatus(SyncStatus.error);
      _lastError = e.toString();
      if (kDebugMode) print('Sync start failed: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void _stopSync() {
    _setStatus(SyncStatus.offline);
    _lastError = null;
    notifyListeners();
  }

  Future<void> _migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final migrated = prefs.getBool('firestore_migrated_${_auth.currentUser?.uid}') ?? false;

    if (!migrated) {
      final localCases = await _localDb.getAllCases();
      if (localCases.isNotEmpty) {
        await _firestore.batchWriteCases(localCases);
      }
      await prefs.setBool('firestore_migrated_${_auth.currentUser?.uid}', true);
    }
  }

  Future<void> manualSync() async {
    if (_auth.currentUser == null) {
      _lastError = 'Not signed in';
      _setStatus(SyncStatus.error);
      notifyListeners();
      return;
    }

    _setStatus(SyncStatus.syncing);
    notifyListeners();

    try {
      final localCases = await _localDb.getAllCases();
      await _firestore.batchWriteCases(localCases);

      _setStatus(SyncStatus.synced);
      _lastSyncedAt = DateTime.now();
      _lastError = null;
    } catch (e) {
      _setStatus(SyncStatus.error);
      _lastError = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void _setStatus(SyncStatus newStatus) {
    _status = newStatus;
  }

  Stream<List<LegalCase>> watchCases() {
    if (_auth.currentUser == null) {
      return _localDbWatchCases();
    }
    return _firestore.watchCases();
  }

  Stream<List<LegalCase>> _localDbWatchCases() async* {
    while (true) {
      yield await _localDb.getAllCases();
      await Future.delayed(const Duration(seconds: 5));
    }
  }
}