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

    // MARK: - Layout Constants

    private enum Layout {
        static let columns = 16
        static let rows = 7
        static let weekLabelWidth: CGFloat = 12
        static let dotSize: CGFloat = 8
        static let rowSpacing: CGFloat = 4
        static let headerSpacing: CGFloat = 12.0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.headerSpacing) {
            header
            dotGrid
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            // Emoji Icon
            Text(habit.icon.contains(".") ? "⭐️" : habit.icon)
                .font(.system(size: 24))

            Text(habit.name)
                .font(.body)
                .fontWeight(.medium)

            Spacer()

            // Use the localized key from HabitFrequency
            Text(habit.frequency.localizationKey)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    private var dotGrid: some View {
        VStack(alignment: .leading, spacing: 2) {
            weekHeaderRow

            ForEach(0..<Layout.rows, id: \.self) { row in
                HStack(spacing: Layout.rowSpacing) {
                    weekIndexLabel(for: row)

                    ForEach(0..<Layout.columns, id: \.self) { col in
                        let totalDaysBack = totalDaysBackForCell(row: row, col: col)
                        let date = Date().daysAgo(totalDaysBack)
                        let isCompleted = viewModel.isHabitCompleted(habit, on: date)
                        let isFuture = date > Date()

                        Circle()
                            .fill(dotColor(isCompleted: isCompleted, isFuture: isFuture))
                            .frame(width: Layout.dotSize, height: Layout.dotSize)
                    }
                }
            }
        }
    }

    private var weekHeaderRow: some View {
        HStack(spacing: 0) {
            Text("weekdayW") // Localized single-letter 'W'
                .font(.system(size: 8))
                .foregroundColor(.gray)
                .frame(width: Layout.weekLabelWidth)

            ForEach(0..<Layout.columns, id: \.self) { _ in
                Color.clear
                    .frame(width: 16, height: 1)
            }
        }
    }

    private func weekIndexLabel(for row: Int) -> some View {
        Text("\(row + 1)")
            .font(.system(size: 8))
            .foregroundColor(.gray)
            .frame(width: Layout.weekLabelWidth)
    }

    // MARK: - Helpers

    private func totalDaysBackForCell(row: Int, col: Int) -> Int {
        // from bottom-right = today, moving left & up
        (Layout.rows - 1 - row) * Layout.columns + (Layout.columns - 1 - col)
    }

    private func dotColor(isCompleted: Bool, isFuture: Bool) -> Color {
        if isFuture {
            return Color.gray.opacity(0.1)
        } else {
            return isCompleted ? habit.colorValue : Color.gray.opacity(0.2)
        }
    }
}

#Preview {
    OverallHabitCard(
        habit: Habit(name: "Meditation", icon: "🧘", color: "green"),
        viewModel: HabitViewModel()
    )
    .padding()
}
