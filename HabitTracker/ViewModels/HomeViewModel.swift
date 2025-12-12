//
//  HomeViewModel.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-12.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var selectedTab: HomeTab = .today
    @Published var selectedTimeFilter: TimeOfDay? = nil

    private let habitVM: HabitViewModel
    private weak var navCoordinator: NavCoordinator?

    private var cancellables = Set<AnyCancellable>()

    init(habitViewModel: HabitViewModel, navCoordinator: NavCoordinator) {
        self.habitVM = habitViewModel
        self.navCoordinator = navCoordinator

        habitViewModel.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    func goToCreateHabit() {
        navCoordinator?.push(.createHabit)
    }

    func goToEditHabit(_ habitId: UUID) {
        navCoordinator?.push(.editHabit(habitId: habitId))
    }

    var todayHabits: [Habit] { habitVM.todayHabits }

    var filteredTodayHabits: [Habit] {
        guard let filter = selectedTimeFilter else { return todayHabits }
        return todayHabits.filter { $0.timeOfDay == filter }
    }

    var activeHabits: [Habit] {
        filteredTodayHabits.filter { !habitVM.isHabitCompleted($0) }
    }

    var completedHabits: [Habit] {
        filteredTodayHabits.filter { habitVM.isHabitCompleted($0) }
    }

    var todayProgress: (completed: Int, total: Int, percentage: Double) {
        let (completed, total) = habitVM.getTodayProgress()
        let percentage = total > 0 ? Double(completed) / Double(total) : 0
        return (completed, total, percentage)
    }

    func toggleHabit(_ habit: Habit) {
        habitVM.toggleHabit(habit)
    }

    var allHabits: [Habit] { habitVM.habits }

    var habitViewModel: HabitViewModel { habitVM }
}

