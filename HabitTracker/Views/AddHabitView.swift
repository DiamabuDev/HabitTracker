//
//  AddHabitView.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitViewModel

    @State private var habitType: HabitType = .regular
    @State private var name = ""
    @State private var selectedIcon = "⭐️"
    @State private var selectedColor = "purple"
    @State private var selectedFrequency: HabitFrequency = .daily
    @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5, 6, 0]
    @State private var selectedTimeOfDay: TimeOfDay? = nil
    @State private var endHabitEnabled = false
    @State private var endDate = Date()
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()

    private let primaryPurple = Color(red: 0.42, green: 0.39, blue: 1.0)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Habit Type Tabs
                    habitTypeTabs

                    // Habit Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Habit Name")
                            .font(.headline)

                        TextField("Habit Name", text: $name)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }

                    // Icon Selection
                    iconSection

                    // Color Selection
                    colorSection

                    // Repeat Section
                    repeatSection

                    // Days Selection (if custom)
                    if selectedFrequency == .custom {
                        daysSection
                    }

                    // Time of Day
                    timeOfDaySection

                    // End Habit Toggle
                    VStack(spacing: 12) {
                        Toggle("End Habit on", isOn: $endHabitEnabled)
                            .font(.body)

                        if endHabitEnabled {
                            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                        }
                    }

                    // Reminder Toggle
                    VStack(spacing: 12) {
                        Toggle("Set Reminder", isOn: $reminderEnabled)
                            .font(.body)

                        if reminderEnabled {
                            DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                        }
                    }

                    // Save Button
                    Button {
                        saveHabit()
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(primaryPurple)
                            .cornerRadius(16)
                    }
                    .disabled(name.isEmpty)
                    .opacity(name.isEmpty ? 0.5 : 1.0)
                }
                .padding()
            }
            .background(Color.white)
            .navigationTitle("Create New Habit")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }

    // MARK: - Habit Type Tabs

    private var habitTypeTabs: some View {
        HStack(spacing: 0) {
            ForEach(HabitType.allCases, id: \.self) { type in
                Button {
                    habitType = type
                } label: {
                    Text(type.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(habitType == type ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(habitType == type ? primaryPurple : Color.white)
                }
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Icon Section

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Icon")
                    .font(.headline)

                Spacer()

                Button {
                    // Show icon picker
                } label: {
                    Text("View All →")
                        .font(.subheadline)
                        .foregroundColor(primaryPurple)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(sampleEmojis, id: \.self) { emoji in
                        Button {
                            selectedIcon = emoji
                        } label: {
                            Text(emoji)
                                .font(.system(size: 32))
                                .frame(width: 50, height: 50)
                                .background(selectedIcon == emoji ? primaryPurple.opacity(0.2) : Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
    }

    private let sampleEmojis = ["🏈", "🏆", "🥇", "🏀", "🏃"]

    // MARK: - Color Section

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Color")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                ForEach(colorOptions, id: \.name) { option in
                    Button {
                        selectedColor = option.name
                    } label: {
                        ZStack {
                            Circle()
                                .fill(option.color)
                                .frame(width: 50, height: 50)

                            if selectedColor == option.name {
                                Circle()
                                    .stroke(Color.primary, lineWidth: 3)
                                    .frame(width: 54, height: 54)
                            }
                        }
                    }
                }
            }
        }
    }

    private let colorOptions: [(name: String, color: Color)] = [
        ("yellow", Color(red: 1.0, green: 1.0, blue: 0.7)),
        ("orange", Color(red: 1.0, green: 0.85, blue: 0.7)),
        ("gray", Color.gray.opacity(0.5)),
        ("brown", Color(red: 0.7, green: 0.6, blue: 0.6)),
        ("pink", Color(red: 1.0, green: 0.7, blue: 0.8)),
        ("rose", Color(red: 1.0, green: 0.8, blue: 0.9)),
        ("magenta", Color(red: 1.0, green: 0.6, blue: 1.0)),
        ("lightpurple", Color(red: 0.9, green: 0.8, blue: 1.0)),
        ("purple", Color(red: 0.75, green: 0.7, blue: 1.0)),
        ("blue", Color(red: 0.7, green: 0.8, blue: 1.0)),
        ("teal", Color(red: 0.7, green: 0.9, blue: 0.9)),
        ("cyan", Color(red: 0.7, green: 1.0, blue: 1.0)),
        ("green", Color(red: 0.7, green: 1.0, blue: 0.8)),
        ("rainbow", Color.pink) // Placeholder for gradient
    ]

    // MARK: - Repeat Section

    private var repeatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Repeat")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach([HabitFrequency.daily, .weekly, .custom], id: \.self) { freq in
                    Button {
                        selectedFrequency = freq
                        if freq == .daily {
                            selectedDays = [0, 1, 2, 3, 4, 5, 6]
                        }
                    } label: {
                        Text(freq.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedFrequency == freq ? .white : .primary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(selectedFrequency == freq ? primaryPurple : Color.white)
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

    // MARK: - Days Section

    private var daysSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("On these day:")
                    .font(.headline)

                Spacer()

                Button {
                    if selectedDays.count == 7 {
                        selectedDays = []
                    } else {
                        selectedDays = [0, 1, 2, 3, 4, 5, 6]
                    }
                } label: {
                    HStack {
                        Text("All day")
                            .font(.subheadline)

                        if selectedDays.count == 7 {
                            Image(systemName: "checkmark")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(primaryPurple)
                }
            }

            HStack(spacing: 8) {
                ForEach(weekdayLabels, id: \.day) { item in
                    Button {
                        if selectedDays.contains(item.day) {
                            selectedDays.remove(item.day)
                        } else {
                            selectedDays.insert(item.day)
                        }
                    } label: {
                        Text(item.label)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(selectedDays.contains(item.day) ? primaryPurple : Color.gray.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }

    private let weekdayLabels = [
        (label: "S", day: 0),
        (label: "M", day: 1),
        (label: "T", day: 2),
        (label: "W", day: 3),
        (label: "T", day: 4),
        (label: "F", day: 5),
        (label: "S", day: 6)
    ]

    // MARK: - Time of Day Section

    private var timeOfDaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Do it at:")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach([TimeOfDay.morning, .afternoon, .evening], id: \.self) { time in
                    Button {
                        if selectedTimeOfDay == time {
                            selectedTimeOfDay = nil
                        } else {
                            selectedTimeOfDay = time
                        }
                    } label: {
                        Text(time.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedTimeOfDay == time ? primaryPurple : .primary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectedTimeOfDay == time ? primaryPurple : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                            .cornerRadius(20)
                    }
                }
            }
        }
    }

    // MARK: - Save Habit

    private func saveHabit() {
        let habit = Habit(
            name: name,
            icon: selectedIcon,
            color: selectedColor,
            category: .other,
            frequency: selectedFrequency,
            reminderTime: reminderEnabled ? reminderTime : nil,
            reminderEnabled: reminderEnabled,
            targetDays: Array(selectedDays).sorted(),
            goal: 1,
            timeOfDay: selectedTimeOfDay
        )

        viewModel.addHabit(habit)
        dismiss()
    }
}

// MARK: - Habit Type Enum

enum HabitType: String, CaseIterable {
    case regular = "Regular Habit"
    case oneTime = "One-time Task"
}

#Preview {
    AddHabitView(viewModel: HabitViewModel())
}
