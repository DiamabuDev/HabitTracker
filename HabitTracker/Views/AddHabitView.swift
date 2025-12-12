//
//  AddHabitView.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    let appViewModel: HabitViewModel

    @StateObject var viewModel: AddHabitViewModel

    init(viewModel: HabitViewModel) {
        self.appViewModel = viewModel
        _viewModel = StateObject(wrappedValue: AddHabitViewModel(appViewModel: viewModel))
    }

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

                        TextField(String(localized: "habitName"), text: $viewModel.name)
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
                    if viewModel.selectedFrequency == .custom {
                        daysSection
                    }

                    // Time of Day
                    timeOfDaySection

                    // End Habit Toggle
                    VStack(spacing: 12) {
                        Toggle(String(localized: "endHabitOn"), isOn: $viewModel.endHabitEnabled)
                            .font(.body)

                        if viewModel.endHabitEnabled {
                            DatePicker(String(localized: "endDate"), selection: $viewModel.endDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                        }
                    }

                    // Reminder Toggle
                    VStack(spacing: 12) {
                        Toggle(String(localized: "setReminder"), isOn: $viewModel.reminderEnabled)
                            .font(.body)

                        if viewModel.reminderEnabled {
                            DatePicker(String(localized: "reminderTime"), selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                        }
                    }

                    // Save Button
                    Button {
                        viewModel.save {
                            dismiss()
                        }
                    } label: {
                        Text("save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.primaryPurple)
                            .cornerRadius(16)
                    }
                    .disabled(viewModel.name.isEmpty)
                    .opacity(viewModel.name.isEmpty ? 0.5 : 1.0)
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
                    viewModel.selectHabitType(type)
                } label: {
                    Text(type.localizationKey)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(viewModel.habitType == type ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(viewModel.habitType == type ? .primaryPurple : .white)
                }
            }
        }
        .background(.gray.opacity(0.1))
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
                    // Show icon picker (future extraction)
                } label: {
                    Text("viewAll")
                        .font(.subheadline)
                        .foregroundColor(.primaryPurple)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.sampleEmojis, id: \.self) { emoji in
                        Button {
                            viewModel.selectIcon(emoji)
                        } label: {
                            Text(emoji)
                                .font(.system(size: 32))
                                .frame(width: 50, height: 50)
                                .background(viewModel.selectedIcon == emoji ? .primaryPurple.opacity(0.2) : .gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Color Section

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("color")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                ForEach(viewModel.colorOptions, id: \.name) { option in
                    Button {
                        viewModel.selectColor(option.name)
                    } label: {
                        ZStack {
                            Circle()
                                .fill(option.color)
                                .frame(width: 50, height: 50)

                            if viewModel.selectedColor == option.name {
                                Circle()
                                    .stroke(.primary, lineWidth: 3)
                                    .frame(width: 54, height: 54)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Repeat Section

    private var repeatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("repeat")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach([HabitFrequency.daily, .weekly, .custom], id: \.self) { freq in
                    Button {
                        viewModel.selectFrequency(freq)
                    } label: {
                        Text(freq.localizationKey)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(viewModel.selectedFrequency == freq ? .white : .primary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(viewModel.selectedFrequency == freq ? .primaryPurple : .white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.gray.opacity(0.3), lineWidth: 1)
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
                    viewModel.toggleAllDays()
                } label: {
                    HStack {
                        Text("allDay")
                            .font(.subheadline)

                        if viewModel.selectedDays.count == 7 {
                            Image(systemName: "checkmark")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primaryPurple)
                }
            }

            HStack(spacing: 8) {
                ForEach(viewModel.weekdayLabels, id: \.day) { item in
                    Button {
                        viewModel.toggleDay(item.day)
                    } label: {
                        Text(item.labelKey)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(viewModel.selectedDays.contains(item.day) ? .primaryPurple : .gray.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }

    // MARK: - Time of Day Section

    private var timeOfDaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("doItAt")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach([TimeOfDay.morning, .afternoon, .evening], id: \.self) { time in
                    Button {
                        viewModel.toggleTimeOfDay(time)
                    } label: {
                        Text(time.localizationKey)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(viewModel.selectedTimeOfDay == time ? .primaryPurple : .primary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(viewModel.selectedTimeOfDay == time ? .primaryPurple : .gray.opacity(0.3), lineWidth: 2)
                            )
                            .cornerRadius(20)
                    }
                }
            }
        }
    }
}

#Preview {
    AddHabitView(viewModel: HabitViewModel())
}
