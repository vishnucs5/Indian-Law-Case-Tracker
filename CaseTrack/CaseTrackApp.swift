import SwiftUI
import SwiftData

@main
struct CaseTrackApp: App {
    @StateObject private var viewModel = CaseViewModel()
    @StateObject private var notificationService = NotificationService.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    DashboardView(viewModel: viewModel)
                }
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.doc.horizontal")
                }

                NavigationStack {
                    AllCasesListView(viewModel: viewModel)
                }
                .tabItem {
                    Label("All Cases", systemImage: "list.bullet")
                }

                NavigationStack {
                    PendingOutcomeView(viewModel: viewModel)
                }
                .tabItem {
                    Label("Pending", systemImage: "exclamationmark.circle")
                }
                .badge(viewModel.pendingOutcomes.isEmpty ? nil : viewModel.pendingOutcomes.count)

                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
            .onAppear {
                Task {
                    _ = await notificationService.requestAuthorization()
                }
                viewModel.refresh()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    viewModel.refresh()
                    viewModel.rescheduleAllNotifications()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .notificationActionReceived)) { notification in
                handleNotificationAction(notification)
            }
        }
    }

    private func handleNotificationAction(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let caseID = userInfo["caseID"] as? UUID,
              let action = userInfo["action"] as? String else { return }

        let allCases = viewModel.allCases
        guard let caseItem = allCases.first(where: { $0.id == caseID }) else { return }

        switch action {
        case "COMPLETED_ACTION":
            viewModel.markCompleted(caseItem)
        case "RESCHEDULED_ACTION":
            // Handled via deep link in a real app; for now, the app shows pending outcomes
            break
        default:
            break
        }
    }
}


