//
//  HomeView.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HabitViewModel
    @State private var selectedTab: HomeTab = .today
    @State private var selectedTimeFilter: TimeOfDay? = nil
    @State private var showAddHabit = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top Tabs
                    topTabsView

                    ScrollView {
                        VStack(spacing: 16) {
                            // Content based on selected tab
                            switch selectedTab {
                            case .today:
                                todayView
                            case .weekly:
                                weeklyView
                            case .overall:
                                overallView
                            }
                        }
                        .padding()
                    }
                }

                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showAddHabit = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color(red: 0.42, green: 0.39, blue: 1.0)) // Purple
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showAddHabit) {
                AddHabitView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Top Tabs

    private var topTabsView: some View {
        HStack(spacing: 12) {
            ForEach(HomeTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTab == tab ? .white : .primary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            selectedTab == tab
                                ? Color(red: 0.42, green: 0.39, blue: 1.0)
                                : Color.gray.opacity(0.1)
                        )
                        .cornerRadius(12)
                }
            }
        }
        .padding()
    }

    // MARK: - Today View

    private var todayView: some View {
        VStack(spacing: 16) {
            // Time Filter Chips
            timeFilterChips

            // Progress Bar
            progressBar

            // Active Habits
            let activeHabits = filteredTodayHabits.filter { !viewModel.isHabitCompleted($0) }
            if !activeHabits.isEmpty {
                ForEach(activeHabits) { habit in
                    HabitCardView(
                        habit: habit,
                        isCompleted: false
                    ) {
                        withAnimation {
                            viewModel.toggleHabit(habit)
                        }
                    }
                }
            }

            // Completed Section
            let completedHabits = filteredTodayHabits.filter { viewModel.isHabitCompleted($0) }
            if !completedHabits.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Completed")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 4)

                    ForEach(completedHabits) { habit in
                        HabitCardView(
                            habit: habit,
                            isCompleted: true
                        ) {
                            withAnimation {
                                viewModel.toggleHabit(habit)
                            }
                        }
                    }
                }
            }

            if filteredTodayHabits.isEmpty {
                emptyStateView
            }
        }
    }

    private var timeFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All filter
                Button {
                    selectedTimeFilter = nil
                } label: {
                    Text("All")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTimeFilter == nil ? .white : .primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            selectedTimeFilter == nil
                                ? Color(red: 0.42, green: 0.39, blue: 1.0)
                                : Color.white
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(20)
                }

                // Time filters
                ForEach(TimeOfDay.allCases, id: \.self) { time in
                    Button {
                        selectedTimeFilter = time
                    } label: {
                        Text(time.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedTimeFilter == time ? .white : .primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                selectedTimeFilter == time
                                    ? Color(red: 0.42, green: 0.39, blue: 1.0)
                                    : Color.white
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(20)
                    }
                }
            }
        }
    }

    private var progressBar: some View {
        let progress = viewModel.getTodayProgress()
        let percentage = progress.total > 0 ? Double(progress.completed) / Double(progress.total) : 0

        return VStack(spacing: 8) {
            HStack {
                Text("Progress")
                    .font(.headline)

                Spacer()

                if progress.completed == progress.total && progress.total > 0 {
                    Text("All Done 🎉")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
            }

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)

                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.green)
                    .frame(width: UIScreen.main.bounds.width * 0.9 * percentage, height: 12)
                    .animation(.easeInOut, value: percentage)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var filteredTodayHabits: [Habit] {
        if let timeFilter = selectedTimeFilter {
            return viewModel.todayHabits.filter { $0.timeOfDay == timeFilter }
        }
        return viewModel.todayHabits
    }

    // MARK: - Weekly View

    private var weeklyView: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.habits) { habit in
                WeeklyHabitCardView(habit: habit, viewModel: viewModel)
            }

            if viewModel.habits.isEmpty {
                emptyStateView
            }
        }
    }

    // MARK: - Overall View

    private var overallView: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.habits) { habit in
                OverallHabitCardView(habit: habit, viewModel: viewModel)
            }

            if viewModel.habits.isEmpty {
                emptyStateView
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))

            Text("No habits for today")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Tap the + button to create your first habit")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
    }
}

// MARK: - Home Tab Enum

enum HomeTab: String, CaseIterable {
    case today = "Today"
    case weekly = "Weekly"
    case overall = "Overall"
}

// MARK: - Habit Card View

struct HabitCardView: View {
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

#Preview {
    HomeView(viewModel: HabitViewModel())
}
