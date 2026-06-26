import SwiftUI

struct AddEditCaseView: View {
    @ObservedObject var viewModel: CaseViewModel
    @Environment(\.dismiss) private var dismiss

    var existingCase: LegalCase?

    @State private var caseNumber = ""
    @State private var caseName = ""
    @State private var customerName = ""
    @State private var caseDate = Date()
    @State private var notes = ""
    @State private var showingError = false

    private var isEditing: Bool { existingCase != nil }

    var body: some View {
        NavigationView {
            Form {
                Section("Case Details") {
                    TextField("Case Number", text: $caseNumber)
                    TextField("Case Name", text: $caseName)
                    TextField("Client Name", text: $customerName)
                }

                Section("Hearing Date") {
                    DatePicker("Date", selection: $caseDate, displayedComponents: .date)
                }

                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle(isEditing ? "Edit Case" : "New Case")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        save()
                    }
                    .disabled(caseNumber.trimmingCharacters(in: .whitespaces).isEmpty
                              || caseName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Missing Information", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Case number and case name are required.")
            }
            .onAppear {
                if let caseItem = existingCase {
                    caseNumber = caseItem.caseNumber
                    caseName = caseItem.caseName
                    customerName = caseItem.customerName
                    caseDate = caseItem.caseDate
                    notes = caseItem.notes ?? ""
                }
            }
        }
    }

    private func save() {
        guard !caseNumber.trimmingCharacters(in: .whitespaces).isEmpty,
              !caseName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showingError = true
            return
        }

        let trimmedNotes = notes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : notes

        if let caseItem = existingCase {
            viewModel.updateCase(caseItem, caseNumber: caseNumber, caseName: caseName, customerName: customerName, caseDate: caseDate, notes: trimmedNotes)
        } else {
            viewModel.addCase(caseNumber: caseNumber, caseName: caseName, customerName: customerName, caseDate: caseDate, notes: trimmedNotes)
        }
        dismiss()
    }
}
