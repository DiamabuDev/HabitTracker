//
//  HabitFrequency.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-12.
//
import SwiftUI

enum HabitFrequency: String, Codable, CaseIterable {
    case daily
    case weekly
    case custom

    var localizationKey: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }

    var description: String {
        NSLocalizedString(rawValue + "_description", comment: "")
    }
}

