import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:casetrack/services/sync_service.dart';
import 'package:casetrack/services/database_service.dart';
import 'package:casetrack/services/firestore_service.dart';
import 'package:casetrack/services/auth_service.dart';
import 'package:casetrack/models/legal_case.dart';

class MockUser extends Fake implements User {
  @override
  String get uid => 'mock_user_123';
}

class MockUserCredential extends Fake implements UserCredential {
  @override
  User? get user => MockUser();
}

class FakeAuthService extends Fake implements AuthService {
  User? _currentUser;
  final _controller = StreamController<User?>.broadcast();

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  Future<UserCredential> signInAnonymously() async {
    _currentUser = MockUser();
    _controller.add(_currentUser);
    return MockUserCredential();
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }
}

class FakeFirestoreService extends Fake implements FirestoreService {
  final List<LegalCase> uploadedCases = [];
  bool wasBatchWriteCalled = false;

  @override
  Future<void> uploadCase(LegalCase legalCase) async {
    uploadedCases.add(legalCase);
  }

  @override
  Future<void> batchWriteCases(List<LegalCase> cases) async {
    wasBatchWriteCalled = true;
    uploadedCases.addAll(cases);
  }

  @override
  Stream<List<LegalCase>> watchCases() {
    return Stream.value(uploadedCases);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncService Tests', () {
    late DatabaseService localDb;
    late FakeFirestoreService firestore;
    late FakeAuthService auth;
    late SyncService syncService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      localDb = DatabaseService();
      firestore = FakeFirestoreService();
      auth = FakeAuthService();
      syncService = SyncService(
        localDb: localDb,
        firestore: firestore,
        auth: auth,
      );
    });

    test('Initializes offline when not signed in', () async {
      await syncService.initialize();
      expect(syncService.status, SyncStatus.offline);
    });

    test('Signs in anonymously and triggers sync/migration', () async {
      // 1. Insert a local case before sync
      final localCase = LegalCase(
        caseNumber: 'LOCAL-100',
        caseName: 'Local Case Description',
        customerName: 'Local Client',
        caseDate: DateTime.now(),
      );
      await localDb.insertCase(localCase);

      await syncService.initialize();
      expect(syncService.status, SyncStatus.offline);

      // 2. Sign in anonymously
      await syncService.signInAnonymously();

      // Give listeners a microtask to fire
      await Future.delayed(const Duration(milliseconds: 10));

      expect(syncService.status, SyncStatus.synced);
      expect(firestore.wasBatchWriteCalled, true);
      expect(firestore.uploadedCases.length, 1);
      expect(firestore.uploadedCases.first.caseNumber, 'LOCAL-100');
    });

    test('Manual sync uploads local cases to cloud', () async {
      await syncService.initialize();
      await syncService.signInAnonymously();
      
      // Clear initial migration uploads
      firestore.uploadedCases.clear();
      firestore.wasBatchWriteCalled = false;

      // Add a case locally
      final newLocalCase = LegalCase(
        caseNumber: 'LOCAL-200',
        caseName: 'Second Case',
        customerName: 'Client B',
        caseDate: DateTime.now(),
      );
      await localDb.insertCase(newLocalCase);

      // Trigger manual sync
      await syncService.manualSync();

      expect(syncService.status, SyncStatus.synced);
      expect(firestore.wasBatchWriteCalled, true);
      expect(firestore.uploadedCases.length, 1);
      expect(firestore.uploadedCases.first.caseNumber, 'LOCAL-200');
    });

    test('Sign out transitions status to offline', () async {
      await syncService.initialize();
      await syncService.signInAnonymously();
      
      // Wait for async sync tasks to resolve
      await Future.delayed(const Duration(milliseconds: 10));
      expect(syncService.status, SyncStatus.synced);

      // Sign out
      await syncService.signOut();
      await Future.delayed(const Duration(milliseconds: 10));

      expect(syncService.status, SyncStatus.offline);
    });
  });
}
