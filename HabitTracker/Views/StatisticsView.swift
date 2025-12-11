//
//  StatisticsView.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: HabitViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Overview Cards
                    overviewSection

                    // Habits Statistics
                    if !viewModel.habits.isEmpty {
                        habitsStatsSection
                    } else {
                        emptyStateView
                    }
                }
                .padding()
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .navigationTitle("Statistics")
        }
    }

    // MARK: - Overview Section

    private var overviewSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Total Habits",
                    value: "\(viewModel.habits.count)",
                    icon: "list.bullet",
                    color: .blue
                )

                StatCard(
                    title: "Active Today",
                    value: "\(viewModel.todayHabits.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }

            HStack(spacing: 12) {
                StatCard(
                    title: "Total Logs",
                    value: "\(viewModel.logs.count)",
                    icon: "chart.bar.fill",
                    color: .orange
                )

                StatCard(
                    title: "Today's Progress",
                    value: todayProgressText,
                    icon: "target",
                    color: .purple
                )
            }
        }
    }

    private var todayProgressText: String {
        let progress = viewModel.getTodayProgress()
        return progress.total > 0 ? "\(Int(Double(progress.completed) / Double(progress.total) * 100))%" : "0%"
    }

    // MARK: - Habits Stats Section

    private var habitsStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Habit Performance")
                .font(.headline)
                .padding(.horizontal, 4)

            ForEach(viewModel.habits) { habit in
                HabitStatRow(
                    habit: habit,
                    currentStreak: viewModel.getCurrentStreak(for: habit),
                    longestStreak: viewModel.getLongestStreak(for: habit),
                    completionRate: viewModel.getCompletionRate(for: habit)
                )
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))

            Text("No Statistics Yet")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Create habits to see your statistics")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)

                Spacer()
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

// MARK: - Habit Stat Row

struct HabitStatRow: View {
    let habit: Habit
    let currentStreak: Int
    let longestStreak: Int
    let completionRate: Double

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(habit.colorValue.opacity(0.2))
                            .frame(width: 40, height: 40)

                        Text(habit.icon.contains(".") ? "⭐️" : habit.icon)
                            .font(.system(size: 20))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(habit.name)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text(habit.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Text("\(Int(completionRate * 100))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(completionRate >= 0.8 ? .green : (completionRate >= 0.5 ? .orange : .red))
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)

                    Rectangle()
                        .fill(habit.colorValue)
                        .frame(width: geometry.size.width * completionRate, height: 6)
                        .cornerRadius(3)
                        .animation(.easeInOut, value: completionRate)
                }
            }
            .frame(height: 6)

            // Stats
            HStack(spacing: 16) {
                StatBadge(
                    label: "Current",
                    value: "\(currentStreak)",
                    icon: "flame.fill",
                    color: .orange
                )

                StatBadge(
                    label: "Longest",
                    value: "\(longestStreak)",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )

                Spacer()

                Text("since \(habit.createdAt.formatted(.dateTime.month(.abbreviated).day()))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

// MARK: - Stat Badge

struct StatBadge: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)

                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    StatisticsView(viewModel: HabitViewModel())
}
