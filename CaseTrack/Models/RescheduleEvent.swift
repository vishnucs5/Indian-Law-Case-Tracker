import SwiftData
import Foundation

@Model
final class RescheduleEvent {
    var id: UUID
    var oldDate: Date
    var newDate: Date
    var changedAt: Date
    var reason: String?
    var legalCase: LegalCase?

    init(oldDate: Date, newDate: Date, reason: String? = nil) {
        self.id = UUID()
        self.oldDate = oldDate
        self.newDate = newDate
        self.changedAt = .now
        self.reason = reason
    }
}
