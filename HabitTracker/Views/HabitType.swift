//
//  HabitType.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import SwiftUI

enum HabitType: String, CaseIterable {
    case regular = "Regular Habit"
    case oneTime = "One-time Task"

    var localizationKey: LocalizedStringKey {
        switch self {
        case .regular: return "regularHabit"
        case .oneTime: return "oneTimeTask"
        }
    }
}
