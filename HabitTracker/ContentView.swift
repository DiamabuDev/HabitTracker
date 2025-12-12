//
//  ContentView.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HabitViewModel()

    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("today", systemImage: "checkmark.circle.fill")
                }

            CalendarView(viewModel: viewModel)
                .tabItem {
                    Label("calendar", systemImage: "calendar")
                }

            StatisticsView(viewModel: viewModel)
                .tabItem {
                    Label("statistics", systemImage: "chart.bar.fill")
                }

            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label("settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
