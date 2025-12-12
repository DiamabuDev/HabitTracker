//
//  WeeklyHabitCardView.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import SwiftUI

struct WeeklyHabitCardView: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitViewModel

    private let weekdaysKeys: [LocalizedStringKey] = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]

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

            // Weekday Grid
            HStack(spacing: 8) {
                ForEach(0..<7) { index in
                    VStack(spacing: 4) {
                        Text(weekdaysKeys[index])
                            .font(.caption2)
                            .foregroundColor(.gray)

                        let date = getDateForWeekday(index)
                        let isCompleted = viewModel.isHabitCompleted(habit, on: date)

                        Button {
                            withAnimation {
                                viewModel.toggleHabit(habit, for: date)
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(isCompleted ? habit.colorValue : Color.gray.opacity(0.1))
                                    .frame(width: 32, height: 32)

                                if isCompleted {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
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

    private func getDateForWeekday(_ index: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)

        // Convert Monday=0 to Calendar weekday (Sunday=1, Monday=2)
        let targetWeekday = (index + 2) % 7
        let adjustedTarget = targetWeekday == 0 ? 7 : targetWeekday

        let daysToAdd = adjustedTarget - weekday
        return calendar.date(byAdding: .day, value: daysToAdd, to: today) ?? today
    }
}

#Preview {
    WeeklyHabitCardView(
        habit: Habit(name: "Meditation", icon: "🧘", color: "green"),
        viewModel: HabitViewModel()
    )
    .padding()
}
