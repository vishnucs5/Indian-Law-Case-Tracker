import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: CaseViewModel

    var body: some View {
        List {
            if viewModel.todaysCases.isEmpty && viewModel.tomorrowsCases.isEmpty {
                ContentUnavailableView(
                    "No Upcoming Cases",
                    systemImage: "calendar.badge.checkmark",
                    description: Text("Cases scheduled for today or tomorrow will appear here.")
                )
            } else {
                if !viewModel.todaysCases.isEmpty {
                    Section("Today") {
                        ForEach(viewModel.todaysCases, id: \.id) { caseItem in
                            NavigationLink(destination: CaseDetailView(caseItem: caseItem, viewModel: viewModel)) {
                                CaseCardView(caseItem: caseItem)
                            }
                        }
                    }
                }

                if !viewModel.tomorrowsCases.isEmpty {
                    Section("Tomorrow") {
                        ForEach(viewModel.tomorrowsCases, id: \.id) { caseItem in
                            NavigationLink(destination: CaseDetailView(caseItem: caseItem, viewModel: viewModel)) {
                                CaseCardView(caseItem: caseItem)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Dashboard")
        .refreshable {
            viewModel.refresh()
        }
    }
}

struct CaseCardView: View {
    let caseItem: LegalCase

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(caseItem.caseNumber)
                .font(.headline)
            Text(caseItem.caseName)
                .font(.subheadline)
            Text(caseItem.customerName)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(caseItem.caseDate.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.blue)
        }
        .padding(.vertical, 4)
    }
}
