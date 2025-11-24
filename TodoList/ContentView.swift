//
//  ContentView.swift
//  TodoList
//
//  Created by Andrew Mankin on 11/15/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Reminder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Reminder.title, ascending: true)],
        animation: .default
    ) var reminders: FetchedResults<Reminder>
    
    @FetchRequest(
        entity: User.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "name == %@", "andrew"),
        animation: .default
    ) var currentUser: FetchedResults<User>
    
    @State private var isAddReminderDialogPresented = false
    
    var body: some View {
        VStack{
            TabView{
                // List Tab
                VStack{
                    List{
                        ForEach(reminders){ reminder in
                            HStack {
                                Image(systemName: reminder.isCompleted
                                      ? "largecircle.fill.circle"
                                      : "circle")
                                .imageScale(.large)
                                .foregroundColor(.accentColor)
                                .onTapGesture {
                                    reminder.isCompleted.toggle()
                                    saveContext()
                                }
                                Text(reminder.title ?? "No Title")
                            }
                        }
                        .onDelete(perform: deleteReminders)
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar){
                            Spacer()
                            Button {
                                isAddReminderDialogPresented.toggle()
                            } label: {
                                Image(systemName: "plus")
                            }
                            
                        }
                    }
                    .sheet(isPresented: $isAddReminderDialogPresented) {
                        ReminderView { title in
                            guard !title.isEmpty else { return }
                            addReminder(title: title)
                            isAddReminderDialogPresented = false
                        }
                    }
                }
                .tabItem{
                    Image(systemName: "house.fill")
                    Text("List")
                }
                
                // USer Tab
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
    
    // Core Data Functions
    private func addReminder(title: String){
        let newReminder = Reminder(context: self.viewContext)
        newReminder.title = title
        newReminder.createdAt = Date()
        newReminder.isCompleted = false
        saveContext()
    }
    
    private func deleteReminders(at offsets: IndexSet){
        offsets.map { reminders[$0]}.forEach(viewContext.delete)
        saveContext()
    }
    
    private func saveContext() {
        print("attempt save")
        do{
            try viewContext.save()
        }catch{
            let nsError = error as NSError
            print("Error saving context: \(nsError), \(nsError.userInfo)")
            //fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}


#Preview {
    let context = PersistenceController.shared.container.viewContext
    ContentView()
        .environment(\.managedObjectContext, context)
        .navigationTitle("Reminders")
}

