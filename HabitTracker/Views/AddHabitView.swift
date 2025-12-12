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
                        Text("habitName")
                            .font(.headline)

                        TextField(String(localized: "habitName"), text: $name)
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
                        Toggle(String(localized: "endHabitOn"), isOn: $endHabitEnabled)
                            .font(.body)

                        if endHabitEnabled {
                            DatePicker(String(localized: "endDate"), selection: $endDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                        }
                    }

                    // Reminder Toggle
                    VStack(spacing: 12) {
                        Toggle(String(localized: "setReminder"), isOn: $reminderEnabled)
                            .font(.body)

                        if reminderEnabled {
                            DatePicker(String(localized: "reminderTime"), selection: $reminderTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                        }
                    }

                    // Save Button
                    Button {
                        saveHabit()
                    } label: {
                        Text("save")
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
            .navigationTitle(Text("createNewHabit"))
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
                            .accessibilityLabel(Text("cancel"))
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
                    Text(type.localizationKey)
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
                Text("icon")
                    .font(.headline)

                Spacer()

                Button {
                    // Show icon picker
                } label: {
                    Text("viewAll")
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
            Text("color")
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
        ("yellow", Color("PastelYellow")),
        ("orange", Color("PastelOrange")),
        ("gray", Color("PastelGray")),
        ("brown", Color("PastelBrown")),
        ("pink", Color("PastelPink")),
        ("rose", Color("PastelRose")),
        ("magenta", Color("PastelMagenta")),
        ("lightpurple", Color("PastelLightPurple")),
        ("purple", Color("PastelPurple")),
        ("blue", Color("PastelBlue")),
        ("teal", Color("PastelTeal")),
        ("cyan", Color("PastelCyan")),
        ("green", Color("PastelGreen")),
        ("rainbow", Color("PastelPink"))
    ]

    // MARK: - Repeat Section

    private var repeatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("repeat")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach([HabitFrequency.daily, .weekly, .custom], id: \.self) { freq in
                    Button {
                        selectedFrequency = freq
                        if freq == .daily {
                            selectedDays = [0, 1, 2, 3, 4, 5, 6]
                        }
                    } label: {
                        Text(freq.localizationKey)
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
                Text("onTheseDays")
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
                        Text("allDay")
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
                        Text(item.labelKey)
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

    private let weekdayLabels: [(labelKey: LocalizedStringKey, day: Int)] = [
        (labelKey: "weekdayS2", day: 0),
        (labelKey: "weekdayM", day: 1),
        (labelKey: "weekdayT", day: 2),
        (labelKey: "weekdayW", day: 3),
        (labelKey: "weekdayT2", day: 4),
        (labelKey: "weekdayF", day: 5),
        (labelKey: "weekdayS", day: 6)
    ]

    // MARK: - Time of Day Section

    private var timeOfDaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("doItAt")
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
                        Text(time.localizationKey)
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

    var localizationKey: LocalizedStringKey {
        switch self {
        case .regular: return "regularHabit"
        case .oneTime: return "oneTimeTask"
        }
    }
}

private extension HabitFrequency {
    var localizationKey: LocalizedStringKey {
        switch self {
        case .daily: return "daily"
        case .weekly: return "weekly"
        case .custom: return "custom"
        }
    }
}

private extension TimeOfDay {
    var localizationKey: LocalizedStringKey {
        switch self {
        case .morning: return "morning"
        case .afternoon: return "afternoon"
        case .evening: return "evening"
        }
    }
}

#Preview {
    AddHabitView(viewModel: HabitViewModel())
}
