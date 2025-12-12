//
//  SettingsViewModel.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-12.
//

import SwiftUI
import Combine

final class SettingsViewModel: ObservableObject {
    // UI state
    @Published var showEditHabit: Habit?
    @Published var showDeleteAlert = false
    @Published var habitToDelete: Habit?
    @Published var showClearDataAlert = false

    // Dependencies
    private let habitViewModel: HabitViewModel

    init(habitViewModel: HabitViewModel) {
        self.habitViewModel = habitViewModel
    }

    // Expose read-only data to the view
    var habits: [Habit] { habitViewModel.habits }
    var logsCount: Int { habitViewModel.logs.count }
    var appVersion: String {
        // You can make this smarter if you want
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    // MARK: - Intents (user actions)

    func didTapHabit(_ habit: Habit) {
        showEditHabit = habit
    }

    func didSwipeToDelete(at offsets: IndexSet) {
        guard let index = offsets.first, habits.indices.contains(index) else { return }
        habitToDelete = habits[index]
        showDeleteAlert = true
    }

    func confirmDelete() {
        guard let habit = habitToDelete else { return }
        habitViewModel.deleteHabit(habit)
        habitToDelete = nil
        showDeleteAlert = false
    }

    func cancelDelete() {
        habitToDelete = nil
        showDeleteAlert = false
    }

    func requestClearAllData() {
        showClearDataAlert = true
    }

    func cancelClearAllData() {
        showClearDataAlert = false
    }

    func confirmClearAllData() {
        habitViewModel.clearAllData()
        showClearDataAlert = false
    }

    // You can expose the underlying HabitViewModel if needed for EditHabitView
    var habitsViewModel: HabitViewModel {
        habitViewModel
    }
}
