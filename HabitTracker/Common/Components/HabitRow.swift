//
//  HabitRow.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import SwiftUI

struct HabitRow: View {
    let habit: Habit
    let isCompleted: Bool
    let streak: Int
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Checkbox
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .stroke(habit.colorValue, lineWidth: 2)
                        .frame(width: 28, height: 28)

                    if isCompleted {
                        Circle()
                            .fill(habit.colorValue)
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())

            // Habit Icon (emoji or SF Symbol fallback)
            if habit.icon.contains(".") {
                // SF Symbol fallback
                ZStack {
                    Circle()
                        .fill(habit.colorValue.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Text("⭐️")
                        .font(.system(size: 24))
                }
            } else {
                // Emoji
                Text(habit.icon)
                    .font(.system(size: 32))
            }

            // Habit Info
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isCompleted ? .secondary : .primary)
                    .strikethrough(isCompleted)

                if !habit.description.isEmpty {
                    Text(habit.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Streak Badge
            if streak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)

                    Text("\(streak)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 12) {
        HabitRow(
            habit: Habit(
                name: "Morning Run",
                description: "Run 5km",
                icon: "figure.run",
                color: "orange",
                category: .fitness
            ),
            isCompleted: false,
            streak: 7
        ) {}

        HabitRow(
            habit: Habit(
                name: "Read Book",
                description: "Read for 30 minutes",
                icon: "book.fill",
                color: "blue",
                category: .learning
            ),
            isCompleted: true,
            streak: 3
        ) {}
    }
    .padding()
    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
}
