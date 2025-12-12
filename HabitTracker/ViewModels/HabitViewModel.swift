//
//  HabitViewModel.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var logs: [HabitLog] = []
    @Published var selectedDate: Date = Date()

    private let coreData = CoreDataManager.shared

    init() {
        loadData()
    }

    // MARK: - Data Management

    func loadData() {
        habits = coreData.fetchHabits()
        logs = coreData.fetchLogs()
    }

    // MARK: - Habit Operations

    func addHabit(_ habit: Habit) {
        _ = coreData.createHabit(from: habit)
        loadData()
    }

    func updateHabit(_ habit: Habit) {
        coreData.updateHabit(habit)
        loadData()
    }

    func deleteHabit(_ habit: Habit) {
        coreData.deleteHabit(habit)
        loadData()
    }
    
    func clearAllData() {
        CoreDataManager.shared.clearAll()
        loadData()
    }


    // MARK: - Log Operations

    func toggleHabit(_ habit: Habit, for date: Date = Date()) {
        let startOfDay = date.startOfDay

        if coreData.isHabitCompleted(habitId: habit.id, on: startOfDay) {
            // Remove log (uncheck)
            coreData.deleteLog(habitId: habit.id, date: startOfDay)
        } else {
            // Add log (check)
            coreData.createLog(habitId: habit.id, date: startOfDay, completed: true, note: nil)
        }
        loadData()
    }

    func isHabitCompleted(_ habit: Habit, on date: Date = Date()) -> Bool {
        coreData.isHabitCompleted(habitId: habit.id, on: date.startOfDay)
    }

    // MARK: - Statistics

    func getCurrentStreak(for habit: Habit) -> Int {
        var streak = 0
        var date = Date().startOfDay

        while true {
            if isHabitCompleted(habit, on: date) {
                streak += 1
                date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
            } else {
                break
            }
        }

        return streak
    }

    func getLongestStreak(for habit: Habit) -> Int {
        let habitLogs = logs.filter { $0.habitId == habit.id }
            .map { $0.date.startOfDay }
            .sorted()

        guard !habitLogs.isEmpty else { return 0 }

        var maxStreak = 1
        var currentStreak = 1

        for i in 1..<habitLogs.count {
            let daysDiff = Calendar.current.dateComponents([.day], from: habitLogs[i-1], to: habitLogs[i]).day ?? 0

            if daysDiff == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }

        return maxStreak
    }

    func getCompletionRate(for habit: Habit) -> Double {
        let daysSinceCreation = Calendar.current.dateComponents([.day], from: habit.createdAt.startOfDay, to: Date().startOfDay).day ?? 0 + 1

        let completedDays = logs.filter { $0.habitId == habit.id }.count

        return daysSinceCreation > 0 ? Double(completedDays) / Double(daysSinceCreation) : 0
    }

    func getTodayProgress() -> (completed: Int, total: Int) {
        let today = Date()
        let todayHabits = habits.filter { habit in
            habit.targetDays.contains(today.dayOfWeek)
        }

        let completed = todayHabits.filter { isHabitCompleted($0, on: today) }.count

        return (completed, todayHabits.count)
    }

    // MARK: - Filtering

    var todayHabits: [Habit] {
        let today = Date()
        return habits.filter { habit in
            habit.targetDays.contains(today.dayOfWeek)
        }.sorted { h1, h2 in
            let c1 = isHabitCompleted(h1)
            let c2 = isHabitCompleted(h2)
            if c1 == c2 {
                return h1.name < h2.name
            }
            return !c1 && c2
        }
    }

    func habitsForDate(_ date: Date) -> [Habit] {
        habits.filter { habit in
            habit.targetDays.contains(date.dayOfWeek)
        }
    }

    func habitsByCategory(_ category: HabitCategory) -> [Habit] {
        habits.filter { $0.category == category }
    }
    
    
}

extension HabitViewModel {
    func habits(on date: Date) -> [Habit] {
        habits.filter { habit in
            habit.targetDays.contains(date.dayOfWeek)
        }
    }

    func completedCount(on date: Date) -> Int {
        habits(on: date).filter { isHabitCompleted($0, on: date) }.count
    }

    func totalCount(on date: Date) -> Int {
        habits(on: date).count
    }

    func completionRate(on date: Date) -> Double {
        let total = totalCount(on: date)
        guard total > 0 else { return 0 }
        return Double(completedCount(on: date)) / Double(total)
    }
}
