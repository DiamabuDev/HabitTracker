//
//  HabitModelTests.swift
//  HabitTrackerTests
//
//  Created by Diana Maldonado on 2025-12-10.
//

import XCTest
@testable import HabitTracker

final class HabitModelTests: XCTestCase {

    // MARK: - Habit Model Tests

    func testHabitInitialization() {
        // Given
        let habit = Habit(
            name: "Morning Run",
            description: "Run 5km",
            icon: "figure.run",
            color: "orange",
            category: .fitness,
            frequency: .daily,
            reminderTime: nil,
            reminderEnabled: false,
            targetDays: [1, 2, 3, 4, 5],
            goal: 1
        )

        // Then
        XCTAssertEqual(habit.name, "Morning Run")
        XCTAssertEqual(habit.description, "Run 5km")
        XCTAssertEqual(habit.icon, "figure.run")
        XCTAssertEqual(habit.color, "orange")
        XCTAssertEqual(habit.category, .fitness)
        XCTAssertEqual(habit.frequency, .daily)
        XCTAssertFalse(habit.reminderEnabled)
        XCTAssertEqual(habit.targetDays, [1, 2, 3, 4, 5])
        XCTAssertEqual(habit.goal, 1)
    }

    func testHabitDefaultValues() {
        // Given
        let habit = Habit(name: "Test Habit")

        // Then
        XCTAssertEqual(habit.name, "Test Habit")
        XCTAssertEqual(habit.description, "")
        XCTAssertEqual(habit.icon, "star.fill")
        XCTAssertEqual(habit.color, "blue")
        XCTAssertEqual(habit.category, .health)
        XCTAssertEqual(habit.frequency, .daily)
        XCTAssertFalse(habit.reminderEnabled)
        XCTAssertEqual(habit.targetDays, [1, 2, 3, 4, 5, 6, 0]) // All days
        XCTAssertEqual(habit.goal, 1)
    }

    func testHabitCodable() throws {
        // Given
        let habit = Habit(
            name: "Read Book",
            description: "Read for 30 minutes",
            icon: "book.fill",
            color: "blue",
            category: .learning,
            frequency: .custom,
            targetDays: [1, 3, 5],
            goal: 1
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(habit)

        let decoder = JSONDecoder()
        let decodedHabit = try decoder.decode(Habit.self, from: data)

        // Then
        XCTAssertEqual(habit.id, decodedHabit.id)
        XCTAssertEqual(habit.name, decodedHabit.name)
        XCTAssertEqual(habit.description, decodedHabit.description)
        XCTAssertEqual(habit.category, decodedHabit.category)
        XCTAssertEqual(habit.frequency, decodedHabit.frequency)
        XCTAssertEqual(habit.targetDays, decodedHabit.targetDays)
    }

    // MARK: - HabitCategory Tests

    func testHabitCategoryIcons() {
        XCTAssertEqual(HabitCategory.health.icon, "heart.fill")
        XCTAssertEqual(HabitCategory.fitness.icon, "figure.run")
        XCTAssertEqual(HabitCategory.productivity.icon, "checkmark.circle.fill")
        XCTAssertEqual(HabitCategory.mindfulness.icon, "brain.head.profile")
        XCTAssertEqual(HabitCategory.learning.icon, "book.fill")
        XCTAssertEqual(HabitCategory.social.icon, "person.2.fill")
        XCTAssertEqual(HabitCategory.creativity.icon, "paintbrush.fill")
        XCTAssertEqual(HabitCategory.finance.icon, "dollarsign.circle.fill")
        XCTAssertEqual(HabitCategory.other.icon, "star.fill")
    }

    func testHabitCategoryRawValues() {
        XCTAssertEqual(HabitCategory.health.rawValue, "Health")
        XCTAssertEqual(HabitCategory.fitness.rawValue, "Fitness")
        XCTAssertEqual(HabitCategory.productivity.rawValue, "Productivity")
    }

    // MARK: - HabitFrequency Tests

    func testHabitFrequencyDescriptions() {
        XCTAssertEqual(HabitFrequency.daily.description, "Every day")
        XCTAssertEqual(HabitFrequency.weekly.description, "Every week")
        XCTAssertEqual(HabitFrequency.custom.description, "Custom days")
    }

    // MARK: - HabitLog Model Tests

    func testHabitLogInitialization() {
        // Given
        let habitId = UUID()
        let date = Date()
        let log = HabitLog(
            habitId: habitId,
            date: date,
            completed: true,
            note: "Felt great!"
        )

        // Then
        XCTAssertEqual(log.habitId, habitId)
        XCTAssertEqual(log.date, date)
        XCTAssertTrue(log.completed)
        XCTAssertEqual(log.note, "Felt great!")
    }

    func testHabitLogDefaultValues() {
        // Given
        let habitId = UUID()
        let log = HabitLog(habitId: habitId)

        // Then
        XCTAssertEqual(log.habitId, habitId)
        XCTAssertTrue(log.completed)
        XCTAssertNil(log.note)
    }

    func testHabitLogCodable() throws {
        // Given
        let log = HabitLog(
            habitId: UUID(),
            date: Date(),
            completed: true,
            note: "Test note"
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(log)

        let decoder = JSONDecoder()
        let decodedLog = try decoder.decode(HabitLog.self, from: data)

        // Then
        XCTAssertEqual(log.id, decodedLog.id)
        XCTAssertEqual(log.habitId, decodedLog.habitId)
        XCTAssertEqual(log.completed, decodedLog.completed)
        XCTAssertEqual(log.note, decodedLog.note)
    }

    // MARK: - Date Extension Tests

    func testDateStartOfDay() {
        // Given
        let calendar = Calendar.current
        let components = DateComponents(year: 2025, month: 12, day: 10, hour: 15, minute: 30)
        let date = calendar.date(from: components)!

        // When
        let startOfDay = date.startOfDay

        // Then
        let startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startOfDay)
        XCTAssertEqual(startComponents.year, 2025)
        XCTAssertEqual(startComponents.month, 12)
        XCTAssertEqual(startComponents.day, 10)
        XCTAssertEqual(startComponents.hour, 0)
        XCTAssertEqual(startComponents.minute, 0)
        XCTAssertEqual(startComponents.second, 0)
    }

    func testDateIsSameDay() {
        // Given
        let calendar = Calendar.current
        let date1 = calendar.date(from: DateComponents(year: 2025, month: 12, day: 10, hour: 10))!
        let date2 = calendar.date(from: DateComponents(year: 2025, month: 12, day: 10, hour: 20))!
        let date3 = calendar.date(from: DateComponents(year: 2025, month: 12, day: 11, hour: 10))!

        // Then
        XCTAssertTrue(date1.isSameDay(as: date2))
        XCTAssertFalse(date1.isSameDay(as: date3))
    }

    func testDateDayOfWeek() {
        // Given
        let calendar = Calendar.current
        // Sunday
        let sunday = calendar.date(from: DateComponents(year: 2025, month: 12, day: 7))!
        // Monday
        let monday = calendar.date(from: DateComponents(year: 2025, month: 12, day: 8))!

        // Then
        XCTAssertEqual(sunday.dayOfWeek, 0) // Sunday = 0
        XCTAssertEqual(monday.dayOfWeek, 1) // Monday = 1
    }
}
