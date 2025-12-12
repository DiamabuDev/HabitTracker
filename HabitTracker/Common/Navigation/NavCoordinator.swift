//
//  NavCoordinator.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-12.
//

import SwiftUI
import Combine

enum Screen: Hashable, Identifiable {
    case home
    case statistics
    case settings

    case createHabit
    case editHabit(habitId: UUID)

    var id: String {
        switch self {
        case .home: return "home"
        case .statistics: return "statistics"
        case .settings: return "settings"
        case .createHabit: return "createHabit"
        case .editHabit(let habitId): return "editHabit-\(habitId.uuidString)"
        }
    }
}

import SwiftUI

@MainActor
final class NavCoordinator: ObservableObject {
    @Published var path: [Screen] = []

    let habitVM = HabitViewModel()

    func push(_ screen: Screen) {
        path.append(screen)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    func popLast(_ k: Int = 1) {
        guard k > 0 else { return }
        let count = min(k, path.count)
        path.removeLast(count)
    }

    func popTo(_ screen: Screen) {
        guard let index = path.lastIndex(of: screen) else { return }
        let removeCount = path.count - index - 1
        if removeCount > 0 { popLast(removeCount) }
    }

    @ViewBuilder
    func build(_ screen: Screen) -> some View {
        switch screen {
        case .home:
            HomeView(habitVM: habitVM, nav: self)

        case .statistics:
            StatisticsView(viewModel: habitVM)

        case .settings:
            SettingsView(viewModel: habitVM)

        case .createHabit:
            HabitFormView(viewModel: habitVM)

        case .editHabit(let habitId):
            HabitFormView(viewModel: habitVM)
        }
    }
}
