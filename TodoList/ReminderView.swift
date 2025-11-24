//
//  ReminderView.swift
//  TodoList
//
//  Created by Andrew Mankin on 11/15/25.
//

import SwiftUI

struct ReminderView: View {
    enum FucusableField: Hashable{
        case title
    }
    
    @FocusState private var focusedField: FucusableField?
    @State private var title = ""
    //@State private var reminder = Reminder(title: "")
    
    @Environment(\.dismiss) private var dismiss
    
    var onCommit: (_ title: String) -> Void
    
    private func commit() {
        onCommit(title)
        dismiss()
     }
    
    private func cancel(){
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form{
                TextField("Title",text: $title)
                    .focused($focusedField, equals: .title)
            }
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button(action: cancel){
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction){
                    Button(action: commit) {
                        Text("Add")
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear{
                focusedField = .title
            }
        }
    }
}

#Preview {
    ReminderView { title in
        print("You added a new reminder titled \(title)")
    }
}
