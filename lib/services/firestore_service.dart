import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/legal_case.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _casesCollection {
    return _firestore.collection('users').doc(_userId).collection('cases');
  }

  CollectionReference<Map<String, dynamic>> _eventsCollection(String caseId) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('cases')
        .doc(caseId)
        .collection('rescheduleEvents');
  }

  Future<void> uploadCase(LegalCase legalCase) async {
    if (_userId.isEmpty) return;

    final caseData = legalCase.toMap();
    caseData['userId'] = _userId;
    caseData['serverCreatedAt'] = FieldValue.serverTimestamp();
    caseData['serverUpdatedAt'] = FieldValue.serverTimestamp();

    await _casesCollection.doc(legalCase.id).set(caseData);

    for (final event in legalCase.rescheduleHistory) {
      await uploadEvent(legalCase.id, event);
    }
  }

  Future<void> uploadEvent(String caseId, RescheduleEvent event) async {
    if (_userId.isEmpty) return;

    final eventData = event.toMap();
    eventData['userId'] = _userId;

    await _eventsCollection(caseId).doc(event.id).set(eventData);
  }

  Future<void> updateCase(LegalCase legalCase) async {
    if (_userId.isEmpty) return;

    final caseData = legalCase.toMap();
    caseData['userId'] = _userId;
    caseData['serverUpdatedAt'] = FieldValue.serverTimestamp();

    await _casesCollection.doc(legalCase.id).update(caseData);
  }

  Future<void> deleteCase(String caseId) async {
    if (_userId.isEmpty) return;

    final eventsSnapshot = await _eventsCollection(caseId).get();
    final batch = _firestore.batch();

    for (final doc in eventsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(_casesCollection.doc(caseId));
    await batch.commit();
  }

  Future<void> deleteEvent(String caseId, String eventId) async {
    if (_userId.isEmpty) return;
    await _eventsCollection(caseId).doc(eventId).delete();
  }

  Stream<List<LegalCase>> watchCases() {
    if (_userId.isEmpty) return Stream.value([]);

    return _casesCollection
        .orderBy('caseDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LegalCase.fromMap(data);
      }).toList();
    });
  }

  Stream<List<RescheduleEvent>> watchEvents(String caseId) {
    if (_userId.isEmpty) return Stream.value([]);

    return _eventsCollection(caseId)
        .orderBy('changedAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RescheduleEvent.fromMap(doc.data())).toList();
    });
  }

  Future<List<LegalCase>> getAllCasesOnce() async {
    if (_userId.isEmpty) return [];

    final snapshot = await _casesCollection.orderBy('caseDate').get();
    return snapshot.docs.map((doc) => LegalCase.fromMap(doc.data())).toList();
  }

  Future<void> batchWriteCases(List<LegalCase> cases) async {
    if (_userId.isEmpty || cases.isEmpty) return;

    final batch = _firestore.batch();

    for (final legalCase in cases) {
      final caseData = legalCase.toMap();
      caseData['userId'] = _userId;
      caseData['serverCreatedAt'] = FieldValue.serverTimestamp();
      caseData['serverUpdatedAt'] = FieldValue.serverTimestamp();

      batch.set(_casesCollection.doc(legalCase.id), caseData);

      for (final event in legalCase.rescheduleHistory) {
        final eventData = event.toMap();
        eventData['userId'] = _userId;
        batch.set(_eventsCollection(legalCase.id).doc(event.id), eventData);
      }
    }

    await batch.commit();
  }
}