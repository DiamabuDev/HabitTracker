//
//  HomeView.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var habitVM: HabitViewModel
    @StateObject private var homeVM: HomeViewModel

    init(habitVM: HabitViewModel, nav: NavCoordinator) {
        self._habitVM = ObservedObject(initialValue: habitVM)
        self._homeVM = StateObject(wrappedValue: HomeViewModel(habitViewModel: habitVM, navCoordinator: nav))
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                MainTitle(title: "home")

                topTabsView

                ScrollView {
                    VStack(spacing: 16) {
                        switch homeVM.selectedTab {
                        case .today: todayView
                        case .weekly: weeklyView
                        case .overall: overallView
                        }
                    }
                    .padding()
                }
            }

            floatingAddButton
        }
    }

    // MARK: - Top Tabs
    private var topTabsView: some View {
        HStack(spacing: 12) {
            ForEach(HomeTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation { homeVM.selectedTab = tab }
                } label: {
                    Text(tab.localizationKey)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(homeVM.selectedTab == tab ? .white : .primary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            homeVM.selectedTab == tab
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
            timeFilterChips
            progressBar

            if !homeVM.activeHabits.isEmpty {
                ForEach(homeVM.activeHabits) { habit in
                    HabitCard(habit: habit, isCompleted: false) {
                        withAnimation { homeVM.toggleHabit(habit) }
                    }
                }
            }

            if !homeVM.completedHabits.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("completed")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 4)

                    ForEach(homeVM.completedHabits) { habit in
                        HabitCard(habit: habit, isCompleted: true) {
                            withAnimation { homeVM.toggleHabit(habit) }
                        }
                    }
                }
            }

            if homeVM.filteredTodayHabits.isEmpty {
                emptyStateView
            }
        }
    }

    private var timeFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button { homeVM.selectedTimeFilter = nil } label: {
                    chipLabel(text: "all", isSelected: homeVM.selectedTimeFilter == nil)
                }

                ForEach(TimeOfDay.allCases, id: \.self) { time in
                    Button { homeVM.selectedTimeFilter = time } label: {
                        chipLabel(text: time.localizationKey, isSelected: homeVM.selectedTimeFilter == time)
                    }
                }
            }
        }
    }

    private func chipLabel(text: LocalizedStringKey, isSelected: Bool) -> some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(isSelected ? Color(red: 0.42, green: 0.39, blue: 1.0) : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(20)
    }

    private var progressBar: some View {
        let progress = homeVM.todayProgress

        return VStack(spacing: 8) {
            HStack {
                Text("progress").font(.headline)
                Spacer()
                if progress.completed == progress.total && progress.total > 0 {
                    Text("allDone")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
            }

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)

                GeometryReader { proxy in
                    let width = proxy.size.width * progress.percentage
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green)
                        .frame(width: width, height: 12)
                        .animation(.easeInOut, value: progress.percentage)
                }
            }
            .frame(height: 12)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var weeklyView: some View {
        VStack(spacing: 16) {
            ForEach(homeVM.allHabits) { habit in
                WeeklyHabitCardView(habit: habit, viewModel: homeVM.habitViewModel)
            }
            if homeVM.allHabits.isEmpty { emptyStateView }
        }
    }

    private var overallView: some View {
        VStack(spacing: 16) {
            ForEach(homeVM.allHabits) { habit in
                OverallHabitCard(habit: habit, viewModel: homeVM.habitViewModel)
            }
            if homeVM.allHabits.isEmpty { emptyStateView }
        }
    }

    private var floatingAddButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    homeVM.goToCreateHabit()
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color(red: 0.42, green: 0.39, blue: 1.0))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))

            Text("noHabitsForToday")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("tapPlusToCreateFirstHabit")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
    }
}

