//
//  Habit.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import Foundation
import SwiftUI

struct Habit: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var description: String
    var icon: String
    var color: String
    var category: HabitCategory
    var frequency: HabitFrequency
    var reminderTime: Date?
    var reminderEnabled: Bool
    var targetDays: [Int]
    var createdAt: Date
    var goal: Int
    var timeOfDay: TimeOfDay?

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        icon: String = "⭐️",
        color: String = "purple",
        category: HabitCategory = .health,
        frequency: HabitFrequency = .daily,
        reminderTime: Date? = nil,
        reminderEnabled: Bool = false,
        targetDays: [Int] = [1, 2, 3, 4, 5, 6, 0],
        createdAt: Date = Date(),
        goal: Int = 1,
        timeOfDay: TimeOfDay? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.color = color
        self.category = category
        self.frequency = frequency
        self.reminderTime = reminderTime
        self.reminderEnabled = reminderEnabled
        self.targetDays = targetDays
        self.createdAt = createdAt
        self.goal = goal
        self.timeOfDay = timeOfDay
    }

    var colorValue: Color {
        switch color.lowercased() {
        case "red", "pink":
            return Color("PastelPink")
        case "purple":
            return Color("PastelPurple")
        case "blue":
            return Color("PastelBlue")
        case "green":
            return Color("PastelGreen")
        case "orange":
            return Color("PastelOrange")
        case "yellow":
            return Color("PastelYellow")
        case "teal":
            return Color("PastelTeal")
        case "gray":
            return Color("PastelGray")
        case "brown":
            return Color("PastelBrown")
        case "rose":
            return Color("PastelRose")
        case "magenta":
            return Color("PastelMagenta")
        case "lightpurple":
            return Color("PastelLightPurple")
        case "cyan":
            return Color("PastelCyan")
        default:
            return Color("PastelGray")
        }
    }
}

struct HabitLog: Identifiable, Codable {
    var id: UUID
    var habitId: UUID
    var date: Date
    var completed: Bool
    var note: String?

    init(
        id: UUID = UUID(),
        habitId: UUID,
        date: Date = Date(),
        completed: Bool = true,
        note: String? = nil
    ) {
        self.id = id
        self.habitId = habitId
        self.date = date
        self.completed = completed
        self.note = note
    }
}

