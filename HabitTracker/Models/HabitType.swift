//
//  HabitType.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import SwiftUI

enum HabitType: String, CaseIterable {
    case regular = "regularHabit"
    case oneTime = "oneTimeTask"

    var localized: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }
}
