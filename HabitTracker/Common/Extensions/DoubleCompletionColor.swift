//
//  Double+CompletionColor.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-12.
//

import SwiftUI

extension Double {
    // Maps a completion rate (0...1) to a color used in the calendar indicators
    var completionColor: Color {
        switch self {
        case let r where r >= 1.0:
            return .green
        case let r where r >= 0.5:
            return .orange
        case let r where r > 0:
            return .yellow
        default:
            return .gray.opacity(0.3)
        }
    }
}

