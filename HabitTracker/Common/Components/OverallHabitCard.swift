//
//  OverallHabitCard.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import SwiftUI

struct OverallHabitCard: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitViewModel

    // Mon..Sun labels (same as WeeklyHabitCard)
    private let weekdaysKeys: [LocalizedStringKey] = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]

    // 4 rows (weeks) x 7 cols (days)
    private let weeksToShow = 4
    private let columns = 7

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
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

            // Weekday labels (single row)
            HStack(spacing: 8) {
                ForEach(0..<columns, id: \.self) { index in
                    Text(weekdaysKeys[index])
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }

            // 4-week grid (circles only)
            VStack(spacing: 10) {
                ForEach(0..<weeksToShow, id: \.self) { weekRow in
                    HStack(spacing: 8) {
                        ForEach(0..<columns, id: \.self) { weekdayIndex in
                            let date = dateForCell(weekRow: weekRow, weekdayIndex: weekdayIndex)
                            let isCompleted = viewModel.isHabitCompleted(habit, on: date)
                            let isFuture = isFutureDate(date)

                            Button {
                                guard !isFuture else { return }
                                withAnimation {
                                    viewModel.toggleHabit(habit, for: date)
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(circleFill(isCompleted: isCompleted, isFuture: isFuture))
                                        .frame(width: 28, height: 28)

                                    if isCompleted && !isFuture {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.plain)
                            .disabled(isFuture)
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

    // MARK: - Frequency label (same behavior as WeeklyHabitCard)
    private var frequencyText: LocalizedStringKey {
        if habit.targetDays.count == 7 {
            return "everyday"
        } else {
            return LocalizedStringKey(
                String(format: String(localized: "daysPerWeekFormat"), habit.targetDays.count)
            )
        }
    }

    // MARK: - Date helpers

    /// weekRow: 0 = oldest week, 3 = current week
    /// weekdayIndex: 0..6 (Mon..Sun)
    private func dateForCell(weekRow: Int, weekdayIndex: Int) -> Date {
        let today = Date().startOfDay
        let startOfThisWeek = today.startOfWeekMonday()

        // weekRow: 0..3 where 3 is current week
        let weeksFromCurrent = weekRow - (weeksToShow - 1) // -3, -2, -1, 0
        let daysOffset = weeksFromCurrent * 7 + weekdayIndex

        // uses your Date.offsetBy(days:)
        return startOfThisWeek.offsetBy(days: daysOffset).startOfDay
    }

    private func isFutureDate(_ date: Date) -> Bool {
        date.startOfDay > Date().startOfDay
    }

    private func circleFill(isCompleted: Bool, isFuture: Bool) -> Color {
        if isFuture {
            return Color.gray.opacity(0.08)
        }
        return isCompleted ? habit.colorValue : Color.gray.opacity(0.12)
    }
}

#Preview {
    OverallHabitCard(
        habit: Habit(name: "Meditation", icon: "🧘", color: "green"),
        viewModel: HabitViewModel()
    )
    .padding()
}
