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
        VStack{
            TabView{
                VStack{
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
                            Spacer()
                            Button(action: presentAddReminderView){
                                HStack{
                                    Image(systemName: "plus")
                                }
                            }
                            
                        }
                    }
                    .sheet(isPresented: $isAddReminderDialogPresented) {
                        ReminderView { reminder in
                            reminders.append(reminder)
                        }
                    }
                }
                .tabItem{
                    Image(systemName: "house.fill")
                    Text("List")
                }
                VStack{
                    Text("User Profile")
                }
                .tabItem{
                    Image(systemName: "person.crop.circle")
                    Text("User")
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .navigationTitle("Reminders")
}
