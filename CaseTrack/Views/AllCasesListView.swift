import SwiftUI

struct AllCasesListView: View {
    @ObservedObject var viewModel: CaseViewModel
    @State private var searchText = ""

    private var groupedCases: [(String, [LegalCase])] {
        let filtered = viewModel.allCases.filter { caseItem in
            if searchText.isEmpty { return true }
            return caseItem.caseNumber.localizedCaseInsensitiveContains(searchText)
                || caseItem.caseName.localizedCaseInsensitiveContains(searchText)
                || caseItem.customerName.localizedCaseInsensitiveContains(searchText)
        }

        let grouped = Dictionary(grouping: filtered) { caseItem in
            caseItem.caseDate.formatted(.dateTime.year().month(.wide))
        }

        return grouped.sorted { $0.key > $1.key }
    }

    var body: some View {
        List {
            if groupedCases.isEmpty {
                ContentUnavailableView(
                    "No Cases",
                    systemImage: "list.bullet.clipboard",
                    description: Text("Add a case to get started.")
                )
            } else {
                ForEach(groupedCases, id: \.0) { month, cases in
                    Section(month) {
                        ForEach(cases, id: \.id) { caseItem in
                            NavigationLink(destination: CaseDetailView(caseItem: caseItem, viewModel: viewModel)) {
                                CaseRowView(caseItem: caseItem)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteCase(caseItem)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    viewModel.markCompleted(caseItem)
                                } label: {
                                    Label("Complete", systemImage: "checkmark.circle")
                                }
                                .tint(.green)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("All Cases")
        .searchable(text: $searchText, prompt: "Search cases...")
        .refreshable {
            viewModel.refresh()
        }
    }
}

struct CaseRowView: View {
    let caseItem: LegalCase

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(caseItem.caseNumber)
                    .font(.headline)
                Spacer()
                Text(caseItem.status.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(statusColor.opacity(0.15))
                    .foregroundStyle(statusColor)
                    .clipShape(Capsule())
            }
            Text(caseItem.caseName)
                .font(.subheadline)
            HStack {
                Text(caseItem.customerName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(caseItem.caseDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 2)
    }

    private var statusColor: Color {
        switch caseItem.status {
        case "completed": return .green
        case "rescheduled": return .orange
        default: return .blue
        }
    }
}
