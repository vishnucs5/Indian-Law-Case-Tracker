import SwiftUI

struct PendingOutcomeView: View {
    @ObservedObject var viewModel: CaseViewModel
    @State private var showingRescheduleFor: LegalCase?

    var body: some View {
        List {
            if viewModel.pendingOutcomes.isEmpty {
                ContentUnavailableView(
                    "All Clear",
                    systemImage: "checkmark.circle",
                    description: Text("No pending outcomes to resolve.")
                )
            } else {
                ForEach(viewModel.pendingOutcomes, id: \.id) { caseItem in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(caseItem.caseNumber)
                            .font(.headline)
                        Text(caseItem.caseName)
                            .font(.subheadline)
                        Text("Was scheduled: \(caseItem.caseDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            Button {
                                viewModel.markCompleted(caseItem)
                            } label: {
                                Label("Completed", systemImage: "checkmark.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(.green.opacity(0.15))
                                    .foregroundStyle(.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }

                            Button {
                                showingRescheduleFor = caseItem
                            } label: {
                                Label("Rescheduled", systemImage: "calendar.badge.clock")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(.orange.opacity(0.15))
                                    .foregroundStyle(.orange)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Pending Outcomes")
        .sheet(item: $showingRescheduleFor) { caseItem in
            RescheduleSheetView(caseItem: caseItem, viewModel: viewModel)
        }
    }
}

extension LegalCase: Identifiable {}
