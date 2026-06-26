import UserNotifications
import Foundation

@MainActor
final class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    private let reminderCategory = "CASE_REMINDER"
    private let checkinCategory = "CASE_CHECKIN"
    private let completedActionID = "COMPLETED_ACTION"
    private let rescheduledActionID = "RESCHEDULED_ACTION"

    override init() {
        super.init()
        center.delegate = self
        setupCategories()
    }

    private func setupCategories() {
        let completedAction = UNNotificationAction(
            identifier: completedActionID,
            title: "Completed",
            options: .foreground
        )
        let rescheduledAction = UNNotificationAction(
            identifier: rescheduledActionID,
            title: "Rescheduled",
            options: .foreground
        )
        let checkinCategory = UNNotificationCategory(
            identifier: checkinCategory,
            actions: [completedAction, rescheduledAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        let reminderCategory = UNNotificationCategory(
            identifier: reminderCategory,
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([reminderCategory, checkinCategory])
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Notification auth error: \(error)")
            return false
        }
    }

    func scheduleReminders(for legalCase: LegalCase, dayBeforeTime: DateComponents? = nil, dayOfTime: DateComponents? = nil) {
        cancelReminders(for: legalCase.id)

        let calendar = Calendar.current

        let dayBeforeHour = dayBeforeTime?.hour ?? 9
        let dayBeforeMinute = dayBeforeTime?.minute ?? 0
        let dayOfHour = dayOfTime?.hour ?? 8
        let dayOfMinute = dayOfTime?.minute ?? 0

        // T-1 day reminder
        if let dayBeforeDate = calendar.date(
            bySettingHour: dayBeforeHour,
            minute: dayBeforeMinute,
            second: 0,
            of: calendar.date(byAdding: .day, value: -1, to: legalCase.caseDate)!
        ), dayBeforeDate > .now {
            let content = UNMutableNotificationContent()
            content.title = "Case Reminder"
            content.body = "\(legalCase.caseNumber) — \(legalCase.caseName) is tomorrow."
            content.sound = .default
            content.categoryIdentifier = reminderCategory
            content.userInfo = ["caseID": legalCase.id.uuidString]

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dayBeforeDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(
                identifier: "\(legalCase.id.uuidString)_dayBefore",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }

        // Day-of check-in
        if let dayOfDate = calendar.date(
            bySettingHour: dayOfHour,
            minute: dayOfMinute,
            second: 0,
            of: legalCase.caseDate
        ), dayOfDate > .now {
            let content = UNMutableNotificationContent()
            content.title = "Case Check-In"
            content.body = "Did \(legalCase.caseNumber) — \(legalCase.caseName) happen today?"
            content.sound = .default
            content.categoryIdentifier = checkinCategory
            content.userInfo = ["caseID": legalCase.id.uuidString]

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dayOfDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(
                identifier: "\(legalCase.id.uuidString)_dayOf",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    func cancelReminders(for caseID: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [
            "\(caseID.uuidString)_dayBefore",
            "\(caseID.uuidString)_dayOf"
        ])
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let caseIDString = userInfo["caseID"] as? String,
              let caseID = UUID(uuidString: caseIDString) else {
            completionHandler()
            return
        }

        let actionID = response.actionIdentifier

        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .notificationActionReceived,
                object: nil,
                userInfo: [
                    "caseID": caseID,
                    "action": actionID
                ]
            )
        }

        completionHandler()
    }
}

extension Notification.Name {
    static let notificationActionReceived = Notification.Name("notificationActionReceived")
}
