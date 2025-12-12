//
//  CalendarView.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: HabitViewModel
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()

    private let calendar = Calendar.current
    private let daysOfWeekKeys: [LocalizedStringKey] = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Calendar Section
                    calendarSection

                    // Selected Date Habits
                    selectedDateSection
                }
                .padding()
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .navigationTitle(Text("calendar"))
        }
    }

    // MARK: - Calendar Section

    private var calendarSection: some View {
        VStack(spacing: 16) {
            // Month Navigation
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.primary)
                        .accessibilityLabel(Text("previous"))
                }

                Spacer()

                Text(currentMonth, format: .dateTime.month(.wide).year())
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(.primary)
                        .accessibilityLabel(Text("next"))
                }
            }

            // Days of Week Header
            HStack(spacing: 0) {
                ForEach(daysOfWeekKeys.indices, id: \.self) { index in
                    Text(daysOfWeekKeys[index])
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(getDaysInMonth(), id: \.self) { date in
                    if let date = date {
                        dayCell(for: date)
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding()
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }

    private func dayCell(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let habitsForDay = viewModel.habitsForDate(date)
        let completedCount = habitsForDay.filter { viewModel.isHabitCompleted($0, on: date) }.count
        let totalCount = habitsForDay.count
        let completionRate = totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 4) {
                Text(date, format: .dateTime.day())
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))

                // Completion Indicator
                if totalCount > 0 {
                    Circle()
                        .fill(getCompletionColor(rate: completionRate))
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isSelected ? Color.blue : Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday && !isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }

    private func getCompletionColor(rate: Double) -> Color {
        if rate == 1.0 {
            return .green
        } else if rate >= 0.5 {
            return .orange
        } else if rate > 0 {
            return .yellow
        } else {
            return .gray.opacity(0.3)
        }
    }

    // MARK: - Selected Date Section

    private var selectedDateSection: some View {
        let habitsForDay = viewModel.habitsForDate(selectedDate)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedDate, format: .dateTime.month(.wide).day().year())
                        .font(.headline)

                    Text(selectedDate, format: .dateTime.weekday(.wide))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Completion Badge
                let completedCount = habitsForDay.filter { viewModel.isHabitCompleted($0, on: selectedDate) }.count
                let totalCount = habitsForDay.count

                if totalCount > 0 {
                    Text("\(completedCount)/\(totalCount)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(completedCount == totalCount ? Color.green : Color.orange)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(.background)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)

            // Habits List
            if habitsForDay.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))

                    Text("noHabitsForToday")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(.background)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
            } else {
                ForEach(habitsForDay) { habit in
                    HabitRowView(
                        habit: habit,
                        isCompleted: viewModel.isHabitCompleted(habit, on: selectedDate),
                        streak: viewModel.getCurrentStreak(for: habit)
                    ) {
                        withAnimation {
                            viewModel.toggleHabit(habit, for: selectedDate)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func getDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }

        var days: [Date?] = []

        // Add empty cells for days before the first day of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }

        // Add all days in the month
        var currentDate = monthInterval.start
        while currentDate < monthInterval.end {
            days.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return days
    }

    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

#Preview {
    CalendarView(viewModel: HabitViewModel())
}
