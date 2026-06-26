import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:casetrack/services/database_service.dart';
import 'package:casetrack/models/legal_case.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatabaseService Tests', () {
    late DatabaseService dbService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      dbService = DatabaseService();
    });

    test('Insert and get all cases', () async {
      final legalCase = LegalCase(
        caseNumber: 'CN12345',
        caseName: 'State vs. John Doe',
        customerName: 'John Doe',
        caseDate: DateTime.now().add(const Duration(days: 2)),
        notes: 'Pre-trial hearing',
      );

      await dbService.insertCase(legalCase);

      final cases = await dbService.getAllCases();
      expect(cases.length, 1);
      expect(cases.first.caseNumber, 'CN12345');
      expect(cases.first.caseName, 'State vs. John Doe');
    });

    test('Update case', () async {
      final legalCase = LegalCase(
        caseNumber: 'CN12345',
        caseName: 'State vs. John Doe',
        customerName: 'John Doe',
        caseDate: DateTime.now().add(const Duration(days: 2)),
      );

      await dbService.insertCase(legalCase);

      legalCase.caseName = 'State vs. Doe (Updated)';
      await dbService.updateCase(legalCase);

      final cases = await dbService.getAllCases();
      expect(cases.length, 1);
      expect(cases.first.caseName, 'State vs. Doe (Updated)');
    });

    test('Delete case', () async {
      final legalCase = LegalCase(
        caseNumber: 'CN12345',
        caseName: 'State vs. John Doe',
        customerName: 'John Doe',
        caseDate: DateTime.now().add(const Duration(days: 2)),
      );

      await dbService.insertCase(legalCase);

      await dbService.deleteCase(legalCase.id);

      final cases = await dbService.getAllCases();
      expect(cases.isEmpty, true);
    });

    test('Get upcoming cases and pending outcomes', () async {
      final now = DateTime.now();

      final upcomingCase = LegalCase(
        caseNumber: 'CN01',
        caseName: 'Upcoming Case',
        customerName: 'Client A',
        caseDate: now.add(const Duration(days: 5)),
        status: 'upcoming',
      );

      final pastCase = LegalCase(
        caseNumber: 'CN02',
        caseName: 'Past Case',
        customerName: 'Client B',
        caseDate: now.subtract(const Duration(days: 2)),
        status: 'upcoming',
      );

      await dbService.insertCase(upcomingCase);
      await dbService.insertCase(pastCase);

      final upcoming = await dbService.getUpcomingCases();
      expect(upcoming.length, 2);

      final pending = await dbService.getPendingOutcomes();
      expect(pending.length, 1);
      expect(pending.first.caseNumber, 'CN02');
    });

    test('Add reschedule event and load history', () async {
      final legalCase = LegalCase(
        caseNumber: 'CN123',
        caseName: 'Test Case',
        customerName: 'Client C',
        caseDate: DateTime.now(),
      );

      await dbService.insertCase(legalCase);

      final event = RescheduleEvent(
        caseId: legalCase.id,
        oldDate: legalCase.caseDate,
        newDate: legalCase.caseDate.add(const Duration(days: 10)),
        reason: 'Witness unavailable',
      );

      await dbService.addRescheduleEvent(event);

      final cases = await dbService.getAllCases();
      expect(cases.length, 1);
      expect(cases.first.rescheduleHistory.length, 1);
      expect(cases.first.rescheduleHistory.first.reason, 'Witness unavailable');
    });
  });
}
