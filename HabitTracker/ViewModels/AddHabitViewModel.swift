//
//  AddHabitViewModel.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import Foundation
import SwiftUI
import Combine


class AddHabitViewModel: ObservableObject {
    private let appViewModel: HabitViewModel

    @Published var habitType: HabitType = .regular
    @Published var name: String = ""
    @Published var selectedIcon: String = "⭐️"
    @Published var selectedColor: String = "purple"
    @Published var selectedFrequency: HabitFrequency = .daily
    @Published var selectedDays: Set<Int> = [0, 1, 2, 3, 4, 5, 6]
    @Published var selectedTimeOfDay: TimeOfDay? = nil
    @Published var endHabitEnabled: Bool = false
    @Published var endDate: Date = Date()
    @Published var reminderEnabled: Bool = false
    @Published var reminderTime: Date = Date()

    // UI Data (could be injected or static)
    let sampleEmojis = ["🏈", "🏆", "🥇", "🏀", "🏃"]

    let colorOptions: [(name: String, color: Color)] = [
        ("yellow", Color("PastelYellow")),
        ("orange", Color("PastelOrange")),
        ("gray", Color("PastelGray")),
        ("brown", Color("PastelBrown")),
        ("pink", Color("PastelPink")),
        ("rose", Color("PastelRose")),
        ("magenta", Color("PastelMagenta")),
        ("lightpurple", Color("PastelLightPurple")),
        ("purple", Color("PastelPurple")),
        ("blue", Color("PastelBlue")),
        ("teal", Color("PastelTeal")),
        ("cyan", Color("PastelCyan")),
        ("green", Color("PastelGreen")),
        ("rainbow", Color("PastelPink"))
    ]

    let weekdayLabels: [(labelKey: LocalizedStringKey, day: Int)] = [
        (labelKey: "weekdayS2", day: 0),
        (labelKey: "weekdayM", day: 1),
        (labelKey: "weekdayT", day: 2),
        (labelKey: "weekdayW", day: 3),
        (labelKey: "weekdayT2", day: 4),
        (labelKey: "weekdayF", day: 5),
        (labelKey: "weekdayS", day: 6)
    ]

    init(appViewModel: HabitViewModel) {
        self.appViewModel = appViewModel
    }

    // MARK: - Intents

    func selectHabitType(_ type: HabitType) {
        habitType = type
    }

    func selectIcon(_ icon: String) {
        selectedIcon = icon
    }

    func selectColor(_ color: String) {
        selectedColor = color
    }

    func selectFrequency(_ frequency: HabitFrequency) {
        selectedFrequency = frequency
        if frequency == .daily {
            selectedDays = [0, 1, 2, 3, 4, 5, 6]
        }
    }

    func toggleDay(_ day: Int) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }

    func toggleAllDays() {
        if selectedDays.count == 7 {
            selectedDays = []
        } else {
            selectedDays = [0, 1, 2, 3, 4, 5, 6]
        }
    }

    func toggleTimeOfDay(_ time: TimeOfDay) {
        if selectedTimeOfDay == time {
            selectedTimeOfDay = nil
        } else {
            selectedTimeOfDay = time
        }
    }

    func save(onSaved: (() -> Void)? = nil) {
        let habit = Habit(
            name: name,
            icon: selectedIcon,
            color: selectedColor,
            category: .other,
            frequency: selectedFrequency,
            reminderTime: reminderEnabled ? reminderTime : nil,
            reminderEnabled: reminderEnabled,
            targetDays: Array(selectedDays).sorted(),
            goal: 1,
            timeOfDay: selectedTimeOfDay
        )

        appViewModel.addHabit(habit)
        onSaved?()
    }
}
