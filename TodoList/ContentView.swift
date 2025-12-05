//
//  ContentView.swift
//  TodoList
//
//  Created by Andrew Mankin on 11/15/25.
//

import SwiftUI
import CoreData

enum ReminderFilter: String, CaseIterable, Identifiable {
    case all = "All Reminders"
    case completed = "Finished"
    case unfinished = "To do"
    var id: Self { self }
}

struct ReminderRow: View {
    @FetchRequest(entity: User.entity(), sortDescriptors: [], animation: .default) var currentUser: FetchedResults<User>
    @FetchRequest(entity: Challenge.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Challenge.startDate, ascending: true)]) var challenges: FetchedResults<Challenge>
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var reminder: Reminder
    var activeTaskCount: Int
    var maxTask: Int = 10
    @State private var showAlert = false

    var body: some View {
      let user = currentUser.first!
        let priorityColor = switch reminder.priority {
            case "High":
                Color.red
            case "Medium":
                Color.orange
            case "Low":
                Color.blue
            default:
                Color.blue
        }
      HStack {
        Button {
            if reminder.isCompleted {
                // try to uncheck
                if activeTaskCount >= maxTask {
                    showAlert = true
                } else {
                    reminder.isCompleted.toggle()
                    user.xp = max(0, user.xp - 5)
                    user.tasksCompleted = max(0, user.tasksCompleted - 1)

                }
            } else { // complete task
                reminder.isCompleted.toggle()
                reminder.completedAt = Date()
                user.tasksCompleted += 1
                user.xp += 5
            }

            do {
                try viewContext.save()
            } catch {
                print("ERROR")
            }
        } label: {
            Image(systemName: reminder.isCompleted ?
                  "checkmark.circle.fill" : "exclamationmark.circle")
            .imageScale(.large)
            .foregroundStyle(reminder.isCompleted ? .gray : priorityColor)
        }.buttonStyle(.plain)
            .alert("Task limit reached!", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            }

        Text(reminder.title ?? "No Title")
        Spacer()
        Text(reminder.dueBy ?? Date(), format: .dateTime.day().month().year())
              .font(Font.caption)
          Image(systemName: "calendar")

      }
      .foregroundStyle(reminder.isCompleted ? .secondary : .primary)
      .strikethrough(reminder.isCompleted)
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Reminder.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Reminder.title, ascending: true)], animation: .default)
    var reminders: FetchedResults<Reminder>
    @FetchRequest(entity: User.entity(), sortDescriptors: [], animation: .default)
    var currentUser: FetchedResults<User>
    @State private var isAddReminderDialogPresented = false
    var activeTaskCount: Int {reminders.filter { !$0.isCompleted }.count}
    var maxTasks: Int = 10

    @State private var selectedFilter: ReminderFilter = .all

    var filteredReminders: [Reminder] {
        switch selectedFilter {
        case .all:
            return reminders.map { $0 }
        case .completed:
            return reminders.filter { $0.isCompleted }
        case .unfinished:
            return reminders.filter { !$0.isCompleted }
        }
    }

    var body: some View {
      VStack {
          TabView {
              if let user = currentUser.first {
                      // List Tab
                      NavigationStack {
                          List {
                              ForEach(filteredReminders) { reminder in
                                  ReminderRow(reminder: reminder, activeTaskCount: activeTaskCount)
                              }
                              .onDelete(perform: deleteReminders)
                          }
                          .toolbar {
                              ToolbarItem(placement: .principal) {
                                  Text("Achievr")
                                      .font(Font.largeTitle.bold())
                              }
                              ToolbarItem(placement: .primaryAction) {
                                  if activeTaskCount < maxTasks {
                                      Button {
                                          isAddReminderDialogPresented.toggle()
                                      } label: {
                                          Image(systemName: "plus")
                                      }
                                  } else {
                                      Image(systemName: "plus")
                                          .foregroundColor(.gray)
                                          .opacity(0.5)
                                  }
                              }
                              ToolbarItem(placement: .topBarLeading) {
                                  Menu {
                                      ForEach(ReminderFilter.allCases) { filter in
                                          Button {
                                              selectedFilter = filter
                                          } label: {
                                              if selectedFilter == filter {
                                                  Text(filter.rawValue)
                                                  Image(systemName: "circle.circle.fill")
                                              } else {
                                                  Text(filter.rawValue)
                                                  Image(systemName: "circle")
                                              }
                                          }
                                      }
                                  } label: {
                                      Image(systemName: "line.3.horizontal.decrease")
                                  }
                              }
                          }
                          .navigationTitle("Tasks")
                          .sheet(isPresented: $isAddReminderDialogPresented) {
                              ReminderView { title, date, priority in
                                  guard !title.isEmpty else { return }
                                  addReminder(title: title, dueBy: date, priority: priority)
                                  isAddReminderDialogPresented = false
                              }
                          }
                      }
                      .tabItem {
                          Image(systemName: "house.fill")
                          Text("Home")
                      }

                      // Calendar tab
                      VStack {
                          CalendarView()
                      }
                      .tabItem {
                          Image(systemName: "calendar")
                          Text("Calendar")
                      }

                      // daily challenges
                      VStack {
                          ChallengeView()
                      }.tabItem {
                          Image(systemName: "text.justify")
                          Text("Challenges")
                      }

                      // USer Tab
                      VStack {
                          ProfileView(user: user)
                      }
                      .tabItem {
                          Image(systemName: "person.crop.circle")
                          Text("User")
                      }
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
    private func addReminder(title: String, dueBy: Date, priority: String) {
        let newReminder = Reminder(context: self.viewContext)
        newReminder.title = title
        newReminder.createdAt = Date()
        newReminder.isCompleted = false
        newReminder.dueBy = dueBy
        newReminder.priority = priority
        saveContext()
    }

  private func deleteReminders(at offsets: IndexSet) {
    offsets.map { reminders[$0]}.forEach(viewContext.delete)
      saveContext()
    }

  private func saveContext() {
    do {
      try viewContext.save()
    } catch {
      let nsError = error as NSError
      print("Error saving context: \(nsError), \(nsError.userInfo)")
    }
  }

  private func loadOrCreateUser(context: NSManagedObjectContext) -> User {
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

