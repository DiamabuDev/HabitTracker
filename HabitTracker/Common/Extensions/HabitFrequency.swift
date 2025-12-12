//
//  HabitFrequencyLocalization.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import SwiftUI

extension HabitFrequency {
    var localizationKey: LocalizedStringKey {
        switch self {
        case .daily: return "daily"
        case .weekly: return "weekly"
        case .custom: return "custom"
        }
    }
}
