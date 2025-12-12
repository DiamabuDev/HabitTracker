//
//  TimeOfDay.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-12.
//

import SwiftUI

enum TimeOfDay: String, Codable, CaseIterable {
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"

    var localizationKey: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }

}
