//
//  HomeTab.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-12.
//

import SwiftUI

enum HomeTab: String, CaseIterable, Hashable {
    case today
    case weekly
    case overall

    var localizationKey: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }
}
