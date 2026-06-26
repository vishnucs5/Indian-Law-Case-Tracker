import SwiftUI
import Combine

@MainActor
final class CaseViewModel: ObservableObject {
    @Published var allCases: [LegalCase] = []
    @Published var upcomingCases: [LegalCase] = []
    @Published var pendingOutcomes: [LegalCase] = []
    @Published var todaysCases: [LegalCase] = []
    @Published var tomorrowsCases: [LegalCase] = []

    private let caseService: CaseService

    init(caseService: CaseService = CaseService()) {
        self.caseService = caseService
    }

    func loadAllCases() {
        allCases = caseService.fetchAllCases()
    }

    func loadUpcomingCases() {
        upcomingCases = caseService.fetchUpcomingCases()
    }

    func loadPendingOutcomes() {
        pendingOutcomes = caseService.fetchPendingOutcomes()
    }

    func loadTodayAndTomorrow() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: today)!

        let todayStart = calendar.startOfDay(for: today)
        let tomorrowStart = calendar.startOfDay(for: tomorrow)

        todaysCases = caseService.fetchAllCases().filter { c in
            let caseDateStart = calendar.startOfDay(for: c.caseDate)
            return c.status == "upcoming" && caseDateStart >= todayStart && caseDateStart < tomorrowStart
        }

        let dayAfterStart = calendar.startOfDay(for: dayAfterTomorrow)
        tomorrowsCases = caseService.fetchAllCases().filter { c in
            let caseDateStart = calendar.startOfDay(for: c.caseDate)
            return c.status == "upcoming" && caseDateStart >= tomorrowStart && caseDateStart < dayAfterStart
        }
    }

    func refresh() {
        loadAllCases()
        loadUpcomingCases()
        loadPendingOutcomes()
        loadTodayAndTomorrow()
    }

    func rescheduleAllNotifications() {
        caseService.rescheduleNotificationsForAll()
    }

    func addCase(caseNumber: String, caseName: String, customerName: String, caseDate: Date, notes: String?) {
        caseService.addCase(caseNumber: caseNumber, caseName: caseName, customerName: customerName, caseDate: caseDate, notes: notes)
        refresh()
    }

    func updateCase(_ legalCase: LegalCase, caseNumber: String, caseName: String, customerName: String, caseDate: Date, notes: String?) {
        caseService.updateCase(legalCase, caseNumber: caseNumber, caseName: caseName, customerName: customerName, caseDate: caseDate, notes: notes)
        refresh()
    }

    func rescheduleCase(_ legalCase: LegalCase, newDate: Date, reason: String? = nil) {
        caseService.rescheduleCase(legalCase, newDate: newDate, reason: reason)
        refresh()
    }

    func markCompleted(_ legalCase: LegalCase) {
        caseService.markCompleted(legalCase)
        refresh()
    }

    func deleteCase(_ legalCase: LegalCase) {
        caseService.deleteCase(legalCase)
        refresh()
    }
}
