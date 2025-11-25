//
//  ContentView.swift
//  TodoList
//
//  Created by Andrew Mankin on 11/15/25.
//

import SwiftUI
import CoreData

struct UserProfile: View {
  @ObservedObject var user: User
  @Environment(\.managedObjectContext) var viewContext
  
  var body: some View {
    VStack{
      Text("User Profile")
      Text("Name: \(user.name ?? "unknown")")
      Text("Level: \(user.level)")
      Text("XP: \(user.xp)")
      Text("Tasks Completed: \(user.tasksCompleted)")
      Text("Created: \(user.createdAt?.formatted(date:.abbreviated,time:.shortened) ?? "")")
    }
      
  }
  private func checkLevelUp(){
    if user.xp >= 100{
      user.level += 1
      user.xp -= 100
    }
    do{
      try viewContext.save()
    }catch{
      print("Error saving user level")
    }
  }
}

struct ReminderRow: View {
  @FetchRequest(entity: User.entity(),sortDescriptors: [],animation: .default) var currentUser: FetchedResults<User>
  @Environment(\.managedObjectContext) var viewContext
  @ObservedObject var reminder: Reminder
  
    var body: some View {
      let user = currentUser.first!
      HStack{
        Button{
          reminder.isCompleted.toggle()
          if reminder.isCompleted{
            user.xp += 5
            user.tasksCompleted += 1
          }else{
            user.xp = max(0,user.xp - 5)
            user.tasksCompleted = max(0,user.tasksCompleted - 1)
          }
          do{
            try viewContext.save()
          }catch{
            print("ERROR")
          }
        } label: {
          Image(systemName: reminder.isCompleted ? "largecircle.fill.circle" : "circle")
            .imageScale(.large)
            .foregroundColor(.accentColor)
        }.buttonStyle(.plain)
        Text(reminder.title ?? "No Title")
      }
    }
}

struct ContentView: View {
  @Environment(\.managedObjectContext) private var viewContext
    
  @FetchRequest(entity: Reminder.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Reminder.title, ascending: true)], animation: .default) var reminders: FetchedResults<Reminder>
    
  @FetchRequest(entity: User.entity(), sortDescriptors: [],animation: .default) var currentUser: FetchedResults<User>
    
  @State private var isAddReminderDialogPresented = false
    
  var body: some View {
    let user = currentUser.first!
      VStack{
          TabView{
              // List Tab
              VStack{
                  List{
                      ForEach(reminders){ reminder in
                          ReminderRow(reminder: reminder)
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
                UserProfile(user: user)
              }
              .tabItem{
                  Image(systemName: "person.crop.circle")
                  Text("User")
              }
          }
          .onAppear {
            if currentUser.first == nil {
              _ = loadOrCreateUser(context: viewContext)
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
    do{
      try viewContext.save()
    }catch{
      let nsError = error as NSError
      print("Error saving context: \(nsError), \(nsError.userInfo)")
    }
  }
  
  private func loadOrCreateUser(context: NSManagedObjectContext) -> User{
    let request: NSFetchRequest<User> = User.fetchRequest()
    
    if let existing = try? context.fetch(request).first {
      return existing
    }
    
    let newUser = User(context: context)
    newUser.id = UUID()
    newUser.name = "LocalUser"
    newUser.level = 1
    newUser.xp = 0
    newUser.tasksCompleted = 0
    newUser.createdAt = Date()
    
    try? context.save()
    return newUser
  }
}

#Preview {
  let context = PersistenceController.shared.container.viewContext
  ContentView()
        .environment(\.managedObjectContext, context)
        .navigationTitle("Reminders")
}

