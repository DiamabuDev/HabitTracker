//
//  StorageManager.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import Foundation

class StorageManager {
    static let shared = StorageManager()

    private let habitsKey = "SavedHabits"
    private let logsKey = "HabitLogs"

    private init() {}

    // MARK: - Habits

    func saveHabits(_ habits: [Habit]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(habits)
            UserDefaults.standard.set(data, forKey: habitsKey)
            print("✅ Saved \(habits.count) habits")
        } catch {
            print("❌ Error saving habits: \(error)")
        }
    }

    func loadHabits() -> [Habit] {
        guard let data = UserDefaults.standard.data(forKey: habitsKey) else {
            print("📱 No saved habits found")
            return []
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let habits = try decoder.decode([Habit].self, from: data)
            print("✅ Loaded \(habits.count) habits")
            return habits
        } catch {
            print("❌ Error loading habits: \(error)")
            return []
        }
    }

    // MARK: - Logs

    func saveLogs(_ logs: [HabitLog]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(logs)
            UserDefaults.standard.set(data, forKey: logsKey)
            print("✅ Saved \(logs.count) logs")
        } catch {
            print("❌ Error saving logs: \(error)")
        }
    }

    func loadLogs() -> [HabitLog] {
        guard let data = UserDefaults.standard.data(forKey: logsKey) else {
            print("📱 No saved logs found")
            return []
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let logs = try decoder.decode([HabitLog].self, from: data)
            print("✅ Loaded \(logs.count) logs")
            return logs
        } catch {
            print("❌ Error loading logs: \(error)")
            return []
        }
    }

    // MARK: - Clear Data

    func clearAll() {
        UserDefaults.standard.removeObject(forKey: habitsKey)
        UserDefaults.standard.removeObject(forKey: logsKey)
        print("🗑️ Cleared all data")
    }
}
