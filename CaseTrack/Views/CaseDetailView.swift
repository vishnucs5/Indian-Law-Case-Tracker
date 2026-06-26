import SwiftUI

struct CaseDetailView: View {
    let caseItem: LegalCase
    @ObservedObject var viewModel: CaseViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingReschedule = false
    @State private var showingDeleteAlert = false

    var body: some View {
        List {
            Section("Case Information") {
                LabeledContent("Case Number", value: caseItem.caseNumber)
                LabeledContent("Case Name", value: caseItem.caseName)
                LabeledContent("Client", value: caseItem.customerName)
                LabeledContent("Hearing Date", value: caseItem.caseDate.formatted(date: .long, time: .shortened))
                LabeledContent("Status", value: caseItem.status.capitalized)
                if let notes = caseItem.notes, !notes.isEmpty {
                    LabeledContent("Notes", value: notes)
                }
            }

            if !caseItem.rescheduleHistory.isEmpty {
                Section("Reschedule History") {
                    ForEach(caseItem.rescheduleHistory.sorted(by: { $0.changedAt > $1.changedAt }), id: \.id) { event in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .foregroundStyle(.orange)
                                Text("\(event.oldDate.formatted(date: .abbreviated, time: .omitted)) → \(event.newDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.subheadline)
                            }
                            Text(event.changedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if let reason = event.reason, !reason.isEmpty {
                                Text("Reason: \(reason)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }

            Section {
                if caseItem.status == "upcoming" {
                    Button {
                        showingReschedule = true
                    } label: {
                        Label("Reschedule", systemImage: "calendar.badge.clock")
                    }

                    Button {
                        viewModel.markCompleted(caseItem)
                    } label: {
                        Label("Mark Completed", systemImage: "checkmark.circle")
                            .foregroundStyle(.green)
                    }
                }

                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete Case", systemImage: "trash")
                }
            }
        }
        .navigationTitle(caseItem.caseNumber)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingReschedule) {
            RescheduleSheetView(caseItem: caseItem, viewModel: viewModel)
        }
        .alert("Delete Case?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteCase(caseItem)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. All case data and history will be permanently removed.")
        }
    }
}
