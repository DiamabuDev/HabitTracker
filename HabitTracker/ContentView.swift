//
//  ContentView.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var nav = NavCoordinator()

    var body: some View {
        NavigationStack(path: $nav.path) {
            TabView {
                nav.build(.home)
                    .tabItem {
                        Label("today", systemImage: "checkmark.circle.fill")
                    }

                nav.build(.statistics)
                    .tabItem {
                        Label("statistics", systemImage: "chart.bar.fill")
                    }

                nav.build(.settings)
                    .tabItem {
                        Label("settings", systemImage: "gear")
                    }
            }
            .navigationDestination(for: Screen.self) { screen in
                nav.build(screen)
            }
        }
    }
}

#Preview {
    ContentView()
}

