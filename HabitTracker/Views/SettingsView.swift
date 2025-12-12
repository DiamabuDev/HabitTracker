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

                                    Text(habit.category.rawValue)
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
                    Text("My Habits")
                } footer: {
                    Text("\(viewModel.habits.count) habit\(viewModel.habits.count != 1 ? "s" : "") total")
                }

                // Data Management
                Section {
                    Button(role: .destructive) {
                        showClearDataAlert = true
                    } label: {
                        Label("Clear All Data", systemImage: "trash")
                    }
                } header: {
                    Text("Data Management")
                } footer: {
                    Text("This will delete all habits and logs. This action cannot be undone.")
                }

                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Total Logs")
                        Spacer()
                        Text("\(viewModel.logs.count)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(item: $showEditHabit) { habit in
                EditHabitView(viewModel: viewModel, habit: habit)
            }
            .alert("Delete Habit", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let habit = habitToDelete {
                        viewModel.deleteHabit(habit)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this habit? All associated logs will also be deleted.")
            }
            .alert("Clear All Data", isPresented: $showClearDataAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    CoreDataManager.shared.save()
                    viewModel.loadData()
                }
            } message: {
                Text("Are you sure you want to delete all habits and logs? This action cannot be undone.")
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
                Section("Basic Information") {
                    TextField("Habit Name", text: $name)
                    TextField("Description (Optional)", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Appearance") {
                    Button {
                        showIconPicker = true
                    } label: {
                        HStack {
                            Text("Icon")
                            Spacer()
                            Text(selectedIcon.contains(".") ? "⭐️" : selectedIcon)
                                .font(.system(size: 24))
                        }
                    }

                    ColorPickerRow(selectedColor: $selectedColor)
                }

                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(HabitCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }

                Section("Frequency") {
                    Picker("Frequency", selection: $selectedFrequency) {
                        ForEach(HabitFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }

                    if selectedFrequency == .custom {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Days")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            WeekdaySelector(selectedDays: $targetDays)
                        }
                    }

                    Stepper("Goal: \(goal) time\(goal > 1 ? "s" : "") per day", value: $goal, in: 1...10)
                }

                Section("Reminder") {
                    Toggle("Enable Reminder", isOn: $reminderEnabled)

                    if reminderEnabled {
                        DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle("Edit Habit")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
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

    private let weekdayLabels = [
        (label: "S", day: 0),
        (label: "M", day: 1),
        (label: "T", day: 2),
        (label: "W", day: 3),
        (label: "T", day: 4),
        (label: "F", day: 5),
        (label: "S", day: 6)
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
                    Text(item.label)
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

    private let emojiCategories: [(name: String, emojis: [String])] = [
        ("Fitness", ["🏃", "🏋️", "🚴", "🏊", "🧘", "🤸", "⛹️", "🚶"]),
        ("Health", ["💊", "🩺", "💉", "🏥", "🧠", "❤️", "🫁", "🦷"]),
        ("Food", ["🥗", "🍎", "🥤", "🍵", "🥛", "🥗", "🍊", "🥕"]),
        ("Learning", ["📚", "📖", "✏️", "📝", "🎓", "🧑‍🎓", "📐", "🔬"]),
        ("Work", ["💼", "💻", "📊", "📈", "🗂️", "📋", "✅", "🖊️"]),
        ("Creative", ["🎨", "🎭", "🎪", "🎬", "📷", "🎵", "🎸", "✍️"]),
        ("Mindfulness", ["🧘", "🕉️", "☮️", "🌸", "🌺", "🍃", "🌿", "💆"]),
        ("Social", ["👥", "🤝", "💬", "📱", "👨‍👩‍👧", "🎉", "🎁", "💌"]),
        ("Money", ["💰", "💵", "💳", "🏦", "📊", "💸", "🪙", "💹"]),
        ("Stars", ["⭐️", "✨", "🌟", "💫", "🌠", "🔆", "☀️", "🌞"])
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(emojiCategories, id: \.name) { category in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category.name)
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
            .navigationTitle("Choose Icon")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: HabitViewModel())
}
