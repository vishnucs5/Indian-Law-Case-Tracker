import SwiftUI

struct RescheduleSheetView: View {
    let caseItem: LegalCase
    @ObservedObject var viewModel: CaseViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var newDate = Date()
    @State private var reason = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Current Date") {
                    LabeledContent("Hearing Date", value: caseItem.caseDate.formatted(date: .long, time: .omitted))
                }

                Section("New Date") {
                    DatePicker("Reschedule To", selection: $newDate, in: Date()..., displayedComponents: .date)
                }

                Section("Reason (Optional)") {
                    TextField("e.g. Judge unavailable", text: $reason)
                }

                Section {
                    Button("Confirm Reschedule") {
                        viewModel.rescheduleCase(caseItem, newDate: newDate, reason: reason.isEmpty ? nil : reason)
                        dismiss()
                    }
                    .disabled(newDate <= caseItem.caseDate)
                }
            }
            .navigationTitle("Reschedule Case")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
