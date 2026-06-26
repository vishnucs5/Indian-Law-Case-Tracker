import SwiftUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("dayBeforeHour") private var dayBeforeHour = 9
    @AppStorage("dayBeforeMinute") private var dayBeforeMinute = 0
    @AppStorage("dayOfHour") private var dayOfHour = 8
    @AppStorage("dayOfMinute") private var dayOfMinute = 0

    @State private var notificationAuthorized = false

    var body: some View {
        List {
            Section("Notification Status") {
                HStack {
                    Label("Notifications", systemImage: "bell")
                    Spacer()
                    if notificationAuthorized {
                        Text("Enabled")
                            .foregroundStyle(.green)
                    } else {
                        Button("Enable") {
                            openSettings()
                        }
                        .foregroundStyle(.red)
                    }
                }
            }

            Section("Reminder Times") {
                HStack {
                    Label("Day-Before Reminder", systemImage: "bell.badge")
                    Spacer()
                    DatePicker(
                        "",
                        selection: Binding(
                            get: {
                                Calendar.current.date(
                                    from: DateComponents(hour: dayBeforeHour, minute: dayBeforeMinute)
                                ) ?? Date()
                            },
                            set: { newDate in
                                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                dayBeforeHour = components.hour ?? 9
                                dayBeforeMinute = components.minute ?? 0
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }

                HStack {
                    Label("Day-Of Check-In", systemImage: "bell.badge.fill")
                    Spacer()
                    DatePicker(
                        "",
                        selection: Binding(
                            get: {
                                Calendar.current.date(
                                    from: DateComponents(hour: dayOfHour, minute: dayOfMinute)
                                ) ?? Date()
                            },
                            set: { newDate in
                                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                dayOfHour = components.hour ?? 8
                                dayOfMinute = components.minute ?? 0
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
            }

            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Developer", value: "CaseTrack")
                Link(destination: URL(string: "https://github.com")!) {
                    Label("GitHub Repository", systemImage: "link")
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            checkNotificationStatus()
        }
    }

    private func checkNotificationStatus() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            notificationAuthorized = settings.authorizationStatus == .authorized
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
