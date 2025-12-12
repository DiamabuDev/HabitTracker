//
//  HabitCategory.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-12.
//
import SwiftUI

enum HabitCategory: String, Codable, CaseIterable {
    case health, fitness, productivity, mindfulness, learning, social, creativity, finance, other

    struct Info {
        let icon: String
        let color: Color
    }

    private var info: Info {
        switch self {
        case .health: return Info(icon: "heart.fill", color: .red)
        case .fitness: return Info(icon: "figure.run", color: .orange)
        case .productivity: return Info(icon: "checkmark.circle.fill", color: .blue)
        case .mindfulness: return Info(icon: "brain.head.profile", color: .purple)
        case .learning: return Info(icon: "book.fill", color: .green)
        case .social: return Info(icon: "person.2.fill", color: .pink)
        case .creativity: return Info(icon: "paintbrush.fill", color: .yellow)
        case .finance: return Info(icon: "dollarsign.circle.fill", color: .cyan)
        case .other: return Info(icon: "star.fill", color: .gray)
        }
    }

    var icon: String { info.icon }
    var color: Color { info.color }

    var localizationKey: LocalizedStringKey {
        LocalizedStringKey(rawValue.lowercased())
    }
}
