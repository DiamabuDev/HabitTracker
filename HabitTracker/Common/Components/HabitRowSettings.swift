//
//  HabitRowSettings.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-12.
//

import SwiftUI

struct HabitRowSettings: View {
    let habit: Habit

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(habit.colorValue.opacity(0.2))
                    .frame(width: 36, height: 36)

                Text(habit.icon.contains(".") ? "⭐️" : habit.icon)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Text(habit.category.localizationKey)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
