//
//  TodoListApp.swift
//  TodoList
//
//  Created by Andrew Mankin on 11/15/25.
//

import SwiftUI

import CoreData

class PersistenceController {
  let container = NSPersistentContainer(name: "Model")

  static let shared = PersistenceController()

  private init() {
    container.loadPersistentStores { description, error in
      if let error = error {
        print("Core Data failed to load: \(error.localizedDescription)")
      }
    }
  }
}

@main
struct TodoListApp: App {
    let persistenceController = PersistenceController.shared
    @State private var loggedInUser: User? = nil
    
  var body: some Scene {
    WindowGroup {
        ContentView()
          .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
