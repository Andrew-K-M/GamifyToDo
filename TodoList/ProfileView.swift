//
//  ProfileView.swift
//  TodoList
//
//  Created by Andrew Mankin on 12/3/25.
//

import SwiftUI
import CoreData

struct ProfileView: View {
    @ObservedObject var user: User
    @Environment(\.managedObjectContext) var viewContext

    var body: some View {
        Form {
            Section(header: Text("Profile")) {
                HStack {
                    Spacer()
                    Image(systemName: "person.crop.circle").resizable().scaledToFit().frame(width: 120, height: 120)
                    Spacer()
                }
                Label("Name: \(user.name ?? "Unknown")", systemImage: "person")
                Label("Level: \(user.level)", systemImage: "star.fill")
                Label("XP: \(user.xp)", systemImage: "bolt.fill")
                Label("Completed: \(user.tasksCompleted)", systemImage: "checkmark.circle")
                Label("Created: \(user.createdAt?.formatted(date: .abbreviated, time: .shortened) ?? "")", systemImage: "calendar")
            }
        }
    }

    private func checkLevelUp() {
        if user.xp >= 100 {
            user.level += 1
            user.xp -= 100
        }
        do {
            try viewContext.save()
        } catch {
            print("Error saving user level")
        }
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    let testUser = User(context: context)
    testUser.name = "Test User"
    testUser.level = 3
    testUser.xp = 50
    testUser.tasksCompleted = 10
    testUser.createdAt = Date()
    return ProfileView(user: testUser).environment(\.managedObjectContext, context)
}
