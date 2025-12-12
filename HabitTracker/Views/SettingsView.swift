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
        NavigationStack {
            Form {
                // Habits Section
                Section {
                    ForEach(viewModel.habits) { habit in
                        Button {
                            showEditHabit = habit
                        } label: {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(habit.colorValue.opacity(0.2))
                                        .frame(width: 36, height: 36)

                                    Text(habit.icon.contains(".") ? "⭐️" : habit.icon)
                                        .font(.system(size: 18))
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(habit.name)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)

                                    Text(habit.category.localizationKey)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
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
                EditHabitView(viewModel: viewModel, habit: habit)
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
            .alert("clearAllDataTitle", isPresented: $showClearDataAlert) {
                Button("cancel", role: .cancel) {}
                Button("clear", role: .destructive) {
                    CoreDataManager.shared.save()
                    viewModel.loadData()
                }
            } message: {
                Text("deleteAllDataWarning")
            }
        }
    }
}

// MARK: - Edit Habit View

struct EditHabitView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitViewModel

    let habit: Habit

    // Habit properties
    @State private var name = ""
    @State private var description = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = "blue"
    @State private var selectedCategory: HabitCategory = .health
    @State private var selectedFrequency: HabitFrequency = .daily
    @State private var targetDays: Set<Int> = [0, 1, 2, 3, 4, 5, 6]
    @State private var goal = 1
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()

    @State private var showIconPicker = false

    init(viewModel: HabitViewModel, habit: Habit) {
        self.viewModel = viewModel
        self.habit = habit

        // Initialize state with habit values
        _name = State(initialValue: habit.name)
        _description = State(initialValue: habit.description)
        _selectedIcon = State(initialValue: habit.icon)
        _selectedColor = State(initialValue: habit.color)
        _selectedCategory = State(initialValue: habit.category)
        _selectedFrequency = State(initialValue: habit.frequency)
        _targetDays = State(initialValue: Set(habit.targetDays))
        _goal = State(initialValue: habit.goal)
        _reminderEnabled = State(initialValue: habit.reminderEnabled)
        _reminderTime = State(initialValue: habit.reminderTime ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("basicInformation") {
                    TextField(String(localized: "habitName"), text: $name)
                    TextField(String(localized: "descriptionOptional"), text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("appearance") {
                    Button {
                        showIconPicker = true
                    } label: {
                        HStack {
                            Text("icon")
                            Spacer()
                            Text(selectedIcon.contains(".") ? "⭐️" : selectedIcon)
                                .font(.system(size: 24))
                        }
                    }

                    ColorPickerRow(selectedColor: $selectedColor)
                }

                Section("category") {
                    Picker(String(localized: "category"), selection: $selectedCategory) {
                        ForEach(HabitCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.localizationKey)
                            }
                            .tag(category)
                        }
                    }
                }

                Section("frequency") {
                    Picker(String(localized: "frequency"), selection: $selectedFrequency) {
                        ForEach(HabitFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.localizationKey).tag(frequency)
                        }
                    }

                    if selectedFrequency == .custom {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("targetDays")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            WeekdaySelector(selectedDays: $targetDays)
                        }
                    }

                    // goalPerDayFormat = "Goal: %d time(s) per day"
                    Stepper(
                        String(
                            format: String(localized: "goalPerDayFormat"),
                            goal
                        ),
                        value: $goal,
                        in: 1...10
                    )
                }

                Section("reminder") {
                    Toggle("enableReminder", isOn: $reminderEnabled)

                    if reminderEnabled {
                        DatePicker("time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle(Text("editHabit"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        saveHabit()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon)
            }
        }
    }

    private func saveHabit() {
        let updatedHabit = Habit(
            id: habit.id,
            name: name,
            description: description,
            icon: selectedIcon,
            color: selectedColor,
            category: selectedCategory,
            frequency: selectedFrequency,
            reminderTime: reminderEnabled ? reminderTime : nil,
            reminderEnabled: reminderEnabled,
            targetDays: selectedFrequency == .custom ? Array(targetDays).sorted() : [0, 1, 2, 3, 4, 5, 6],
            createdAt: habit.createdAt,
            goal: goal
        )

        viewModel.updateHabit(updatedHabit)
        dismiss()
    }
}

// MARK: - Color Picker Row

struct ColorPickerRow: View {
    @Binding var selectedColor: String

    private let colorOptions: [(name: String, color: Color)] = [
        ("yellow", Color("PastelYellow")),
        ("orange", Color("PastelOrange")),
        ("gray", Color("PastelGray")),
        ("pink", Color("PastelPink")),
        ("purple", Color("PastelPurple")),
        ("blue", Color("PastelBlue")),
        ("teal", Color("PastelTeal")),
        ("green", Color("PastelGreen"))
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(colorOptions, id: \.name) { option in
                    Button {
                        selectedColor = option.name
                    } label: {
                        ZStack {
                            Circle()
                                .fill(option.color)
                                .frame(width: 40, height: 40)

                            if selectedColor == option.name {
                                Circle()
                                    .stroke(Color.primary, lineWidth: 3)
                                    .frame(width: 44, height: 44)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Weekday Selector

struct WeekdaySelector: View {
    @Binding var selectedDays: Set<Int>

    private let weekdayLabels: [(labelKey: LocalizedStringKey, day: Int)] = [
        (labelKey: "weekdayS", day: 0),
        (labelKey: "weekdayM", day: 1),
        (labelKey: "weekdayT", day: 2),
        (labelKey: "weekdayW", day: 3),
        (labelKey: "weekdayT", day: 4),
        (labelKey: "weekdayF", day: 5),
        (labelKey: "weekdayS", day: 6)
    ]

    var body: some View {
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
                        .background(selectedDays.contains(item.day) ? Color.blue : Color.gray.opacity(0.3))
                        .clipShape(Circle())
                }
            }
        }
    }
}

// MARK: - Icon Picker View

struct IconPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedIcon: String

    private let emojiCategories: [(nameKey: LocalizedStringKey, emojis: [String])] = [
        ("fitness", ["🏃", "🏋️", "🚴", "🏊", "🧘", "🤸", "⛹️", "🚶"]),
        ("health", ["💊", "🩺", "💉", "🏥", "🧠", "❤️", "🫁", "🦷"]),
        ("food", ["🥗", "🍎", "🥤", "🍵", "🥛", "🥗", "🍊", "🥕"]),
        ("learning", ["📚", "📖", "✏️", "📝", "🎓", "🧑‍🎓", "📐", "🔬"]),
        ("work", ["💼", "💻", "📊", "📈", "🗂️", "📋", "✅", "🖊️"]),
        ("creative", ["🎨", "🎭", "🎪", "🎬", "📷", "🎵", "🎸", "✍️"]),
        ("mindfulness", ["🧘", "🕉️", "☮️", "🌸", "🌺", "🍃", "🌿", "💆"]),
        ("social", ["👥", "🤝", "💬", "📱", "👨‍👩‍👧", "🎉", "🎁", "💌"]),
        ("money", ["💰", "💵", "💳", "🏦", "📊", "💸", "🪙", "💹"]),
        ("stars", ["⭐️", "✨", "🌟", "💫", "🌠", "🔆", "☀️", "🌞"])
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(emojiCategories.indices, id: \.self) { index in
                        let category = emojiCategories[index]
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category.nameKey)
                                .font(.headline)
                                .foregroundColor(.primary)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                ForEach(category.emojis, id: \.self) { emoji in
                                    Button {
                                        selectedIcon = emoji
                                        dismiss()
                                    } label: {
                                        Text(emoji)
                                            .font(.system(size: 32))
                                            .frame(width: 50, height: 50)
                                            .background(selectedIcon == emoji ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(Text("chooseIcon"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private extension HabitCategory {
    var localizationKey: LocalizedStringKey {
        switch self {
        case .health: return "health"
        case .fitness: return "fitness"
        case .productivity: return "productivity"
        case .mindfulness: return "mindfulness"
        case .learning: return "learning"
        case .social: return "social"
        case .creativity: return "creativity"
        case .finance: return "finance"
        case .other: return "other"
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

#Preview {
    SettingsView(viewModel: HabitViewModel())
}
