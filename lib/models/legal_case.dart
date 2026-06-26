import 'package:uuid/uuid.dart';

class LegalCase {
  final String id;
  String caseNumber;
  String caseName;
  String customerName;
  DateTime caseDate;
  String status;
  String? notes;
  final DateTime createdAt;
  DateTime updatedAt;
  List<RescheduleEvent> rescheduleHistory;
  final String userId;
  DateTime? serverCreatedAt;
  DateTime? serverUpdatedAt;

  LegalCase({
    String? id,
    required this.caseNumber,
    required this.caseName,
    required this.customerName,
    required this.caseDate,
    this.status = 'upcoming',
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<RescheduleEvent>? rescheduleHistory,
    this.userId = '',
    this.serverCreatedAt,
    this.serverUpdatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        rescheduleHistory = rescheduleHistory ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'caseNumber': caseNumber,
      'caseName': caseName,
      'customerName': customerName,
      'caseDate': caseDate.toIso8601String(),
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      'serverCreatedAt': serverCreatedAt?.toIso8601String(),
      'serverUpdatedAt': serverUpdatedAt?.toIso8601String(),
    };
  }

  factory LegalCase.fromMap(Map<String, dynamic> map, [List<RescheduleEvent>? history]) {
    return LegalCase(
      id: map['id'],
      caseNumber: map['caseNumber'],
      caseName: map['caseName'],
      customerName: map['customerName'],
      caseDate: DateTime.parse(map['caseDate']),
      status: map['status'],
      notes: map['notes'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
      rescheduleHistory: history ?? [],
      userId: map['userId'] ?? '',
      serverCreatedAt: map['serverCreatedAt'] != null ? DateTime.parse(map['serverCreatedAt']) : null,
      serverUpdatedAt: map['serverUpdatedAt'] != null ? DateTime.parse(map['serverUpdatedAt']) : null,
    );
  }

  LegalCase copyWith({
    String? caseNumber,
    String? caseName,
    String? customerName,
    DateTime? caseDate,
    String? status,
    String? notes,
  }) {
    return LegalCase(
      id: id,
      caseNumber: caseNumber ?? this.caseNumber,
      caseName: caseName ?? this.caseName,
      customerName: customerName ?? this.customerName,
      caseDate: caseDate ?? this.caseDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      rescheduleHistory: rescheduleHistory,
    );
  }
}

class RescheduleEvent {
  final String id;
  final String caseId;
  final DateTime oldDate;
  final DateTime newDate;
  final DateTime changedAt;
  final String? reason;
  final String userId;

  RescheduleEvent({
    String? id,
    required this.caseId,
    required this.oldDate,
    required this.newDate,
    DateTime? changedAt,
    this.reason,
    this.userId = '',
  })  : id = id ?? const Uuid().v4(),
        changedAt = changedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'caseId': caseId,
      'oldDate': oldDate.toIso8601String(),
      'newDate': newDate.toIso8601String(),
      'changedAt': changedAt.toIso8601String(),
      'reason': reason,
      'userId': userId,
    };
  }

  factory RescheduleEvent.fromMap(Map<String, dynamic> map) {
    return RescheduleEvent(
      id: map['id'],
      caseId: map['caseId'],
      oldDate: DateTime.parse(map['oldDate']),
      newDate: DateTime.parse(map['newDate']),
      changedAt: DateTime.parse(map['changedAt']),
      reason: map['reason'],
      userId: map['userId'] ?? '',
    );
  }
}
