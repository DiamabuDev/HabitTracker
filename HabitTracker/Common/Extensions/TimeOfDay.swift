//
//  TimeOfDayLocalization.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import SwiftUI

extension TimeOfDay {
    var localizationKey: LocalizedStringKey {
        switch self {
        case .morning: return "morning"
        case .afternoon: return "afternoon"
        case .evening: return "evening"
        }
    }
}
