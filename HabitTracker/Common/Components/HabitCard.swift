//
//  HabitCard.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-12.
//
import SwiftUI

struct HabitCard: View {
    let habit: Habit
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Emoji Icon (or default if SF Symbol)
                Text(habit.icon.contains(".") ? "⭐️" : habit.icon)
                    .font(.system(size: 32))

                // Habit Name
                Text(habit.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.black)

                Spacer()

                // Checkmark for completed
                if isCompleted {
                    ZStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(habit.colorValue)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
