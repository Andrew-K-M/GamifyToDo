//
//  ProfileView.swift
//  TodoList
//
//  Created by Andrew Mankin on 12/3/25.
//

import SwiftUI
import CoreData

//MARK: Avatars
struct Avatar: Identifiable {
    let id: String
    let emoji: String
    let requiredLevel: Int
}

let allAvatars: [Avatar] = [
    .init(id: "wilt",emoji: "🥀",requiredLevel: 1),
    .init(id: "star",emoji: "💫",requiredLevel: 5),
    .init(id: "ice", emoji: "🥶",requiredLevel: 10),
    .init(id: "tired",emoji: "🫩",requiredLevel: 15),
    .init(id: "devil",emoji: "😈",requiredLevel: 20),
    .init(id: "alien",emoji: "👽",requiredLevel: 30),
    .init(id: "goat",emoji: "🐐",requiredLevel: 40),
]

// MARK: ProfileView
struct ProfileView: View {
    @ObservedObject var user: User
    @Environment(\.managedObjectContext) var viewContext

    var body: some View {
        Form {
            Section(header: Text("Profile")) {
                HStack {
                    Spacer()
                    Text(user.currentPicture ?? "🙂").font(.system(size: 120))
                    Spacer()
                }
                Label("Name: \(user.name ?? "Unknown")", systemImage: "person")
                Label("Level: \(user.level)", systemImage: "star.fill")
                Label("XP: \(user.xp)", systemImage: "bolt.fill")
                Label("Completed: \(user.tasksCompleted)", systemImage: "checkmark.circle")
                Label("Created: \(user.createdAt?.formatted(date: .abbreviated, time: .shortened) ?? "")", systemImage: "calendar")
            }
            Section(header: Text("Choose Your Avatar")){
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        ForEach(allAvatars){ avatar in
                            let unlocked = user.level >= avatar.requiredLevel
                            VStack {
                                ZStack{
                                    if user.currentPicture == avatar.emoji {
                                        Circle()
                                            .fill(Color.blue)
                                            .opacity(0.3)
                                            .frame(width: 70, height: 70)
                                    }
                                    Text(avatar.emoji)
                                        .font(.system(size: 50))
                                        .opacity(unlocked ? 1.0 : 0.35)
                                }
                                
                                Text("Lvl \(avatar.requiredLevel)")
                                    .font(.caption)
                                
                                if !unlocked {
                                    Image(systemName: "lock.fill")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }.onTapGesture {
                                if unlocked{
                                    user.currentPicture = avatar.emoji
                                    try? viewContext.save()
                                }
                            }
                        }
                    }.padding(.horizontal)
                }
            }
        }.onAppear{
            checkLevelUp()
        }
    }
    //MARK: Check for level up
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

// MARK: Preview
#Preview {
    let context = PersistenceController.shared.container.viewContext
    let testUser = User(context: context)
    testUser.name = "Test User"
    testUser.level = 3
    testUser.xp = 50
    testUser.tasksCompleted = 10
    testUser.createdAt = Date()
    testUser.currentPicture = "🌚"
    return ProfileView(user: testUser).environment(\.managedObjectContext, context)
}
