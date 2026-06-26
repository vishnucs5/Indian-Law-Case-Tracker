import SwiftData
import Foundation

@MainActor
final class CaseService: ObservableObject {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    private let notificationService: NotificationService

    init(notificationService: NotificationService = .shared) {
        self.notificationService = notificationService
        let schema = Schema([LegalCase.self, RescheduleEvent.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        self.modelContainer = try! ModelContainer(for: schema, configurations: [config])
        self.modelContext = modelContainer.mainContext
    }

    func fetchAllCases() -> [LegalCase] {
        let descriptor = FetchDescriptor<LegalCase>(sortBy: [SortDescriptor(\.caseDate)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchUpcomingCases() -> [LegalCase] {
        let descriptor = FetchDescriptor<LegalCase>(
            predicate: #Predicate<LegalCase> { $0.status == "upcoming" },
            sortBy: [SortDescriptor(\.caseDate)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchCasesForDate(_ date: Date) -> [LegalCase] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let descriptor = FetchDescriptor<LegalCase>(
            predicate: #Predicate<LegalCase> {
                $0.status == "upcoming" && $0.caseDate >= startOfDay && $0.caseDate < endOfDay
            },
            sortBy: [SortDescriptor(\.caseDate)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchPendingOutcomes() -> [LegalCase] {
        let startOfToday = Calendar.current.startOfDay(for: .now)
        let descriptor = FetchDescriptor<LegalCase>(
            predicate: #Predicate<LegalCase> {
                $0.status == "upcoming" && $0.caseDate < startOfToday
            },
            sortBy: [SortDescriptor(\.caseDate)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func addCase(caseNumber: String, caseName: String, customerName: String, caseDate: Date, notes: String?) {
        let legalCase = LegalCase(
            caseNumber: caseNumber,
            caseName: caseName,
            customerName: customerName,
            caseDate: caseDate
        )
        legalCase.notes = notes
        modelContext.insert(legalCase)
        save()
        notificationService.scheduleReminders(for: legalCase)
    }

    func updateCase(_ legalCase: LegalCase, caseNumber: String, caseName: String, customerName: String, caseDate: Date, notes: String?) {
        legalCase.caseNumber = caseNumber
        legalCase.caseName = caseName
        legalCase.customerName = customerName
        legalCase.notes = notes

        if legalCase.caseDate != caseDate {
            let event = RescheduleEvent(oldDate: legalCase.caseDate, newDate: caseDate)
            legalCase.rescheduleHistory.append(event)
            modelContext.insert(event)
            legalCase.caseDate = caseDate
        }

        legalCase.updatedAt = .now
        save()
        notificationService.scheduleReminders(for: legalCase)
    }

    func rescheduleCase(_ legalCase: LegalCase, newDate: Date, reason: String? = nil) {
        let event = RescheduleEvent(oldDate: legalCase.caseDate, newDate: newDate, reason: reason)
        legalCase.rescheduleHistory.append(event)
        modelContext.insert(event)
        legalCase.caseDate = newDate
        legalCase.status = "upcoming"
        legalCase.updatedAt = .now
        save()
        notificationService.cancelReminders(for: legalCase.id)
        notificationService.scheduleReminders(for: legalCase)
    }

    func markCompleted(_ legalCase: LegalCase) {
        legalCase.status = "completed"
        legalCase.updatedAt = .now
        save()
        notificationService.cancelReminders(for: legalCase.id)
    }

    func deleteCase(_ legalCase: LegalCase) {
        notificationService.cancelReminders(for: legalCase.id)
        modelContext.delete(legalCase)
        save()
    }

    func rescheduleNotificationsForAll() {
        let upcoming = fetchUpcomingCases()
        for caseItem in upcoming {
            notificationService.scheduleReminders(for: caseItem)
        }
    }

    private func save() {
        try? modelContext.save()
    }
}
