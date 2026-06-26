import SwiftData
import Foundation

@Model
final class LegalCase {
    var id: UUID
    var caseNumber: String
    var caseName: String
    var customerName: String
    var caseDate: Date
    var status: String
    var notes: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \RescheduleEvent.legalCase)
    var rescheduleHistory: [RescheduleEvent] = []

    init(caseNumber: String, caseName: String, customerName: String, caseDate: Date) {
        self.id = UUID()
        self.caseNumber = caseNumber
        self.caseName = caseName
        self.customerName = customerName
        self.caseDate = caseDate
        self.status = "upcoming"
        self.notes = nil
        self.createdAt = .now
        self.updatedAt = .now
    }
}
