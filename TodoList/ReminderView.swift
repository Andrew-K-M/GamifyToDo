//
//  ReminderView.swift
//  TodoList
//
//  Created by Andrew Mankin on 11/15/25.
//

import SwiftUI

struct ReminderView: View {
    enum FocusableField: Hashable {
        case title
    }

    @FocusState private var focusedField: FocusableField?
    @State private var title = ""
    @State private var dueBy = Date()
    @State private var priority: String = "Medium"
    // @State private var reminder = Reminder(title: "")

    @Environment(\.dismiss) private var dismiss

    let options = ["High", "Medium", "Low"]
    var onCommit: (_ title: String, _ dueBy: Date, _ priority: String) -> Void

    private func commit() {
        onCommit(title, dueBy, priority)
        dismiss()
     }

    private func cancel() {
        dismiss()
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title).focused($focusedField, equals: .title)
                DatePicker("Due Date", selection: $dueBy)
                Picker("Select an option", selection: $priority) {
                    ForEach(options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.menu) // This makes it behave like a dropdown
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: cancel) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: commit) {
                        Text("Add")
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                focusedField = .title
            }
        }
    }
}

#Preview {
    ReminderView { title, date, priority in
        print("Added reminder: \(title), \(date), due: \(priority)")
    }
}
