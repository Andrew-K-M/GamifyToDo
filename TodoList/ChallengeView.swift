//
//  ChallengeView.swift
//  TodoList
//
//  Created by Andrew Mankin on 12/3/25.
//

import SwiftUI
import CoreData

struct ChallengeTemplate {
    let title: String
    let type: String   // "daily" or "weekly"
    let goal: Int      // Number of tasks to complete
    let rewardXP: Int
}

let dailyTemplates = [
    ChallengeTemplate(title: "Complete 3 tasks today", type: "daily", goal: 3, rewardXP: 10),
    ChallengeTemplate(title: "Finish 2 medium task", type: "daily", goal: 2, rewardXP: 15),
    ChallengeTemplate(title: "Complete 5 tasks today", type: "daily", goal: 5, rewardXP: 20)
]

let weeklyTemplates = [
    ChallengeTemplate(title: "Complete 20 medium tasks this week", type: "weekly", goal: 20, rewardXP: 50),
    ChallengeTemplate(title: "Finish 5 high priority tasks", type: "weekly", goal: 5, rewardXP: 40),
    ChallengeTemplate(title: "Complete 30 tasks this week", type: "weekly", goal: 30, rewardXP: 60)
]

//MARK: ChallengeRow
struct ChallengeRow: View{ //to make update in real time
    @ObservedObject var challenge: Challenge
    
    var body: some View{
        HStack {
            VStack(alignment: .leading) {
                Text(challenge.title ?? "No Title")
                    .font(.headline)
                Text("\(challenge.currentProgress)/\(challenge.goal) tasks completed")
                    .font(.caption)
            }
            Spacer()
            if challenge.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
}


// MARK: ChallengeView
struct ChallengeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Challenge.entity(),sortDescriptors: [NSSortDescriptor(keyPath: \Challenge.startDate, ascending: true)]) var challenges: FetchedResults<Challenge>
    @FetchRequest(entity: Reminder.entity(),sortDescriptors: []) var reminders: FetchedResults<Reminder>
    @FetchRequest(entity: User.entity(),sortDescriptors: []) var currentUser: FetchedResults<User>
    
    var body: some View{
        List {
            Section(header:Text("Daily Challenges")){
                ForEach(challenges.filter{$0.type == "daily"}) { challenge in
                    ChallengeRow(challenge: challenge)
                }
            }
            Section(header:Text("Weekly Challenges")){
                ForEach(challenges.filter{$0.type == "weekly"}) { challenge in
                    ChallengeRow(challenge: challenge)
                }
            }
            
        }
        .onAppear {
            deleteExpiredChallenges()
            generateChallengesIfNeeded()
            updateChallengeProgress()
        }
    }
    
    // MARK: - Generate Challenges
    private func generateChallengesIfNeeded() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        
        // Daily Challenges
        if !challenges.contains(where: { $0.type == "daily" && $0.startDate == today }) {
            for template in dailyTemplates {
                let challenge = Challenge(context: viewContext)
                challenge.id = UUID()
                challenge.title = template.title
                challenge.type = template.type
                challenge.startDate = today
                challenge.endDate = calendar.date(byAdding: .day, value: 1, to: today)!
                challenge.isCompleted = false
                challenge.goal = Int16(template.goal)
                challenge.currentProgress = 0
                challenge.rewardXP = Int64(template.rewardXP)
                
                try? viewContext.save()
            }
        }
        // Weekly Challenges
        if !challenges.contains(where: { $0.type == "weekly" && $0.startDate == weekStart }) {
            for template in weeklyTemplates {
                let challenge = Challenge(context: viewContext)
                challenge.id = UUID()
                challenge.title = template.title
                challenge.type = template.type
                challenge.startDate = weekStart
                challenge.endDate = calendar.date(byAdding: .day, value: 7, to: weekStart)!
                challenge.isCompleted = false
                challenge.goal = Int16(template.goal)
                challenge.currentProgress = 0
                challenge.rewardXP = Int64(template.rewardXP)
            }
        }

        saveContext()
    }
    
    // MARK: - Update Challenge Progress
    private func updateChallengeProgress(){
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        for challenge in challenges{
            if challenge.isCompleted { continue }
            
            let relevantTasks: Int
            switch challenge.type {
            case "daily":
                if challenge.title == "Finish 1 medium task"{
                    relevantTasks = reminders.filter{
                        $0.isCompleted && $0.priority == "Medium" && ($0.completedAt ?? Date()) >= today
                    }.count
                }else { //generic case (just complete any)
                    relevantTasks = reminders.filter{
                        $0.isCompleted && ($0.completedAt ?? Date()) >= today
                    }.count
                }
            case "weekly":
                if challenge.title == "Complete 20 medium tasks this week"{
                    relevantTasks = reminders.filter{
                        $0.isCompleted && $0.priority == "Medium" && ($0.completedAt ?? Date()) >= weekStart
                    }.count
                }else if challenge.title == "Finish 5 high priority tasks"{
                    relevantTasks = reminders.filter{
                        $0.isCompleted && $0.priority == "High" && ($0.completedAt ?? Date()) >= weekStart
                    }.count
                }else {
                    relevantTasks = reminders.filter{
                        $0.isCompleted && ($0.completedAt ?? Date()) >= weekStart
                    }.count
                }
                
            default:
                relevantTasks = 0
            }
            
            challenge.currentProgress = Int16(relevantTasks)
            if challenge.currentProgress >= challenge.goal{
                if challenge.currentProgress > challenge.goal{
                    challenge.currentProgress = challenge.goal
                }
                challenge.isCompleted = true
                currentUser.first!.xp += challenge.rewardXP
            }
        }
    }
    
    //MARK: Update when past endDate
    private func deleteExpiredChallenges(){
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        
        // check if the date is after the endDate
        for challenge in challenges{
            switch challenge.type{
            case "daily":
                if let endDate = challenge.endDate, endDate < today{
                    viewContext.delete(challenge)
                }
            case "weekly":
                if let endDate = challenge.endDate, endDate < weekStart{
                    viewContext.delete(challenge)
                }
            default:
                break
            }
            
        }
        saveContext()
    }
    
    // MARK: - Helpers
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }

}

//#Preview {
//    ChallengeView()
//}
