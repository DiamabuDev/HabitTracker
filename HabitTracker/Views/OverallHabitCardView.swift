//
//  OverallHabitCardView.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import SwiftUI

struct OverallHabitCardView: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitViewModel

    private let columns = 16
    private let rows = 7

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Emoji Icon
                Text(habit.icon.contains(".") ? "⭐️" : habit.icon)
                    .font(.system(size: 24))

                Text(habit.name)
                    .font(.body)
                    .fontWeight(.medium)

                Spacer()

                Text(frequencyText)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // Dot Grid
            VStack(alignment: .leading, spacing: 2) {
                // Week labels
                HStack(spacing: 0) {
                    Text("weekdayW") // Using single-letter 'W' key from your list
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                        .frame(width: 12)

                    ForEach(0..<columns, id: \.self) { _ in
                        Color.clear.frame(width: 16, height: 1)
                    }
                }

                // Dot rows
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 4) {
                        // Week number
                        Text("\(row + 1)")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                            .frame(width: 12)

                        // Dots for each day
                        ForEach(0..<columns, id: \.self) { col in
                            let date = getDate(forRow: row, col: col)
                            let isCompleted = viewModel.isHabitCompleted(habit, on: date)
                            let isFuture = date > Date()

                            Circle()
                                .fill(isFuture ? Color.gray.opacity(0.1) : (isCompleted ? habit.colorValue : Color.gray.opacity(0.2)))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var frequencyText: LocalizedStringKey {
        if habit.targetDays.count == 7 {
            return "everyday"
        } else {
            // daysPerWeekFormat = "%d days per week"
            return LocalizedStringKey(String(format: String(localized: "daysPerWeekFormat"), habit.targetDays.count))
        }
    }

    private func getDate(forRow row: Int, col: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()

        // Calculate total days back from today
        let totalDays = (rows - 1 - row) * columns + (columns - 1 - col)
        return calendar.date(byAdding: .day, value: -totalDays, to: today) ?? today
    }
}

#Preview {
    OverallHabitCardView(
        habit: Habit(name: "Meditation", icon: "🧘", color: "green"),
        viewModel: HabitViewModel()
    )
    .padding()
}
