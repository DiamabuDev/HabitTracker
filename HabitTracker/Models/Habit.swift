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
    var targetDays: [Int] // 0=Sunday, 1=Monday, etc.
    var createdAt: Date
    var goal: Int // How many times per frequency period
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
        targetDays: [Int] = [1, 2, 3, 4, 5, 6, 0], // All days
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

enum TimeOfDay: String, Codable, CaseIterable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
}

enum HabitCategory: String, Codable, CaseIterable {
    case health = "Health"
    case fitness = "Fitness"
    case productivity = "Productivity"
    case mindfulness = "Mindfulness"
    case learning = "Learning"
    case social = "Social"
    case creativity = "Creativity"
    case finance = "Finance"
    case other = "Other"

    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .fitness: return "figure.run"
        case .productivity: return "checkmark.circle.fill"
        case .mindfulness: return "brain.head.profile"
        case .learning: return "book.fill"
        case .social: return "person.2.fill"
        case .creativity: return "paintbrush.fill"
        case .finance: return "dollarsign.circle.fill"
        case .other: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .health: return .red
        case .fitness: return .orange
        case .productivity: return .blue
        case .mindfulness: return .purple
        case .learning: return .green
        case .social: return .pink
        case .creativity: return .yellow
        case .finance: return .cyan
        case .other: return .gray
        }
    }
}

enum HabitFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case custom = "Custom"

    var description: String {
        switch self {
        case .daily: return "Every day"
        case .weekly: return "Every week"
        case .custom: return "Custom days"
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

// Extension for date comparison
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }

    var dayOfWeek: Int {
        Calendar.current.component(.weekday, from: self) - 1
    }
}
