//
//  ContentView.swift
//  TodoList
//
//  Created by Andrew Mankin on 11/15/25.
//

import SwiftUI

struct ContentView: View {
    @State
    private var reminders = Reminder.samples
    
    @State
    private var isAddReminderDialogPresented = false
    
    private func presentAddReminderView(){
        isAddReminderDialogPresented.toggle()
    }
    
    var body: some View {
        List($reminders){ $reminder in
            HStack {
                Image(systemName: reminder.isCompleted
                      ? "largecircle.fill.circle"
                      : "circle")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        reminder.isCompleted.toggle()
                    }
                Text(reminder.title)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar){
                Button(action: presentAddReminderView){
                    HStack{
                        Image(systemName: "plus.cicrle.fill")
                        Text("New Reminder")
                    }
                }
                Spacer()
            }
        }
        .sheet(isPresented: $isAddReminderDialogPresented) {
            ReminderView { reminder in
                reminders.append(reminder)
            }
        }
    }
}

#Preview {
    ContentView()
        .navigationTitle("Reminders")
}
