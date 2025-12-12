//
//  SettingsView.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: HabitViewModel
    @State private var showEditHabit: Habit?
    @State private var showDeleteAlert = false
    @State private var habitToDelete: Habit?
    @State private var showClearDataAlert = false
    
    var body: some View {
        VStack {
            MainTitle(title: "settings")

            Form {
                // Habits Section
                Section {
                    ForEach(viewModel.habits) { habit in
                        Button {
                            showEditHabit = habit
                        } label: {
                            HabitRowSettings(habit: habit)
                        }
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            habitToDelete = viewModel.habits[index]
                            showDeleteAlert = true
                        }
                    }
                } header: {
                    Text("myHabits")
                } footer: {
                    Text("\(viewModel.habits.count) habit\(viewModel.habits.count != 1 ? "s" : "") total")
                }
                
                // Data Management
                Section {
                    Button(role: .destructive) {
                        showClearDataAlert = true
                    } label: {
                        Label(String(localized: "clearAllData"), systemImage: "trash")
                    }
                } header: {
                    Text("dataManagement")
                } footer: {
                    Text("deleteAllDataWarning")
                }
                
                // About Section
                Section("about") {
                    HStack {
                        Text("version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("totalLogs")
                        Spacer()
                        Text("\(viewModel.logs.count)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(Text("settings"))
            .sheet(item: $showEditHabit) { habit in
                HabitFormView(viewModel: viewModel)
            }
            .alert("deleteHabit", isPresented: $showDeleteAlert) {
                Button("cancel", role: .cancel) {}
                Button("delete", role: .destructive) {
                    if let habit = habitToDelete {
                        viewModel.deleteHabit(habit)
                    }
                }
            } message: {
                Text("deleteHabitConfirmMessage")
            }
            .alert("clearAllData", isPresented: $showClearDataAlert) {
                Button("cancel", role: .cancel) {}
                Button("clear", role: .destructive) {
                    viewModel.clearAllData()
                }
            } message: {
                Text("deleteAllDataWarning")
            }
        }
    }
}
