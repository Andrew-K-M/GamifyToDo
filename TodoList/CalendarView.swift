//
//  CalendarView.swift
//  TodoList
//
//  Created by Ryan Safarzadeh on 12/2/25.
//

import SwiftUI
import CoreData

// MARK: - Calendar View
struct CalendarView: View {
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date?

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Reminder.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Reminder.title, ascending: true)], animation: .default) var tasks: FetchedResults<Reminder>
    @FetchRequest(entity: User.entity(), sortDescriptors: [], animation: .default) var currentUser: FetchedResults<User>

    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        VStack(spacing: 20) {
            // Month Navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }

                Spacer()

                Text(monthYearString(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            // Days of Week Header
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)

            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 12) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate ?? Date.distantPast),
                            isToday: calendar.isDateInToday(date),
                            taskCount: tasksCount(for: date),
                            hasCompletedTasks: hasCompletedTasks(for: date)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
            .padding(.horizontal)

            // Tasks for Selected Date
            if let selected = selectedDate {
                TaskListView(date: selected, tasks: tasks(for: selected))
            }

            Spacer()
        }
        .padding(.top)
    }

    // MARK: - Helper Functions

    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let _ = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        let numDays = calendar.dateComponents([.day], from: monthInterval.start, to: monthInterval.end).day ?? 0

        var days: [Date?] = []
        let weekdayOffset = calendar.component(.weekday, from: monthInterval.start) - 1

        // Add empty cells for days before month starts
        for _ in 0..<weekdayOffset {
            days.append(nil)
        }

        // Add all days in month
        for day in 0..<numDays {
            if let date = calendar.date(byAdding: .day, value: day, to: monthInterval.start) {
                days.append(date)
            }
        }

        return days
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }

    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }

    private func tasksCount(for date: Date) -> Int {
        tasks.filter { calendar.isDate($0.dueBy!, inSameDayAs: date) }.count
    }

    private func hasCompletedTasks(for date: Date) -> Bool {
        tasks.contains { calendar.isDate($0.dueBy!, inSameDayAs: date) && $0.isCompleted }
    }

    private func tasks(for date: Date) -> [Reminder] {
        tasks.filter { calendar.isDate($0.dueBy!, inSameDayAs: date) }
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let taskCount: Int
    let hasCompletedTasks: Bool

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: isToday ? .bold : .regular))
                .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.1) : Color.clear))
                )

            // Task indicator dots
            if taskCount > 0 {
                HStack(spacing: 2) {
                    ForEach(0..<min(taskCount, 3), id: \.self) { _ in
                        Circle()
                            .fill(hasCompletedTasks ? Color.gray : Color.orange)
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .frame(height: 50)
    }
}

// MARK: - Task List View
struct TaskListView: View {
    let date: Date
    let tasks: [Reminder]

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(dateFormatter.string(from: date))
                .font(.headline)
                .padding(.horizontal)

            if tasks.isEmpty {
                Text("No tasks for this day")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(tasks) { task in
                            let priorityColor = switch task.priority {
                            case "High":
                                Color.red
                            case "Medium":
                                    Color.yellow
                            default:
                                    Color.blue
                            }
                            HStack {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "exclamationmark.circle")
                                    .foregroundColor(task.isCompleted ? .gray : priorityColor)

                                Text(task.title!)
                                    .strikethrough(task.isCompleted)
                                    .foregroundColor(task.isCompleted ? .secondary : .primary)

                                Spacer()
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxHeight: 200)
    }
}

// MARK: - Preview
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
