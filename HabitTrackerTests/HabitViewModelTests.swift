//
//  HabitViewModelTests.swift
//  HabitTrackerTests
//
//  Created by Diana Maldonado on 2025-12-10.
//

import XCTest
import CoreData
@testable import HabitTracker

@MainActor
final class HabitViewModelTests: XCTestCase {

    var viewModel: HabitViewModel!
    var mockCoreDataStack: NSPersistentContainer!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory Core Data stack for testing
        mockCoreDataStack = NSPersistentContainer(name: "HabitTracker")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        mockCoreDataStack.persistentStoreDescriptions = [description]

        mockCoreDataStack.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }

        viewModel = HabitViewModel()
    }

    override func tearDown() async throws {
        viewModel = nil
        mockCoreDataStack = nil
        try await super.tearDown()
    }

    // MARK: - Habit Operations Tests

    func testAddHabit() {
        // Given
        let habit = Habit(
            name: "Morning Exercise",
            description: "30 minutes workout",
            category: .fitness
        )
        let initialCount = viewModel.habits.count

        // When
        viewModel.addHabit(habit)

        // Then
        XCTAssertEqual(viewModel.habits.count, initialCount + 1)
        XCTAssertTrue(viewModel.habits.contains { $0.name == "Morning Exercise" })
    }

    func testUpdateHabit() {
        // Given
        var habit = Habit(name: "Original Name", category: .health)
        viewModel.addHabit(habit)

        // When
        habit.name = "Updated Name"
        habit.description = "New description"
        viewModel.updateHabit(habit)

        // Then
        let updatedHabit = viewModel.habits.first { $0.id == habit.id }
        XCTAssertEqual(updatedHabit?.name, "Updated Name")
        XCTAssertEqual(updatedHabit?.description, "New description")
    }

    func testDeleteHabit() {
        // Given
        let habit = Habit(name: "To Delete", category: .other)
        viewModel.addHabit(habit)
        let initialCount = viewModel.habits.count

        // When
        viewModel.deleteHabit(habit)

        // Then
        XCTAssertEqual(viewModel.habits.count, initialCount - 1)
        XCTAssertFalse(viewModel.habits.contains { $0.id == habit.id })
    }

    // MARK: - Log Operations Tests

    func testToggleHabitCompletion() {
        // Given
        let habit = Habit(name: "Test Habit", category: .health)
        viewModel.addHabit(habit)
        let today = Date()

        // When - Complete habit
        XCTAssertFalse(viewModel.isHabitCompleted(habit, on: today))
        viewModel.toggleHabit(habit, for: today)

        // Then
        XCTAssertTrue(viewModel.isHabitCompleted(habit, on: today))

        // When - Uncomplete habit
        viewModel.toggleHabit(habit, for: today)

        // Then
        XCTAssertFalse(viewModel.isHabitCompleted(habit, on: today))
    }

    func testToggleHabitMultipleDays() {
        // Given
        let habit = Habit(name: "Test Habit", category: .health)
        viewModel.addHabit(habit)

        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        // When
        viewModel.toggleHabit(habit, for: today)
        viewModel.toggleHabit(habit, for: yesterday)

        // Then
        XCTAssertTrue(viewModel.isHabitCompleted(habit, on: today))
        XCTAssertTrue(viewModel.isHabitCompleted(habit, on: yesterday))
    }

    // MARK: - Streak Calculation Tests

    func testGetCurrentStreakNoCompletion() {
        // Given
        let habit = Habit(name: "Test Habit", category: .health)
        viewModel.addHabit(habit)

        // When
        let streak = viewModel.getCurrentStreak(for: habit)

        // Then
        XCTAssertEqual(streak, 0)
    }

    func testGetCurrentStreakWithCompletion() {
        // Given
        let habit = Habit(name: "Test Habit", category: .health)
        viewModel.addHabit(habit)

        let calendar = Calendar.current
        let today = Date()

        // Complete habit for the last 3 days
        for i in 0..<3 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            viewModel.toggleHabit(habit, for: date)
        }

        // When
        let streak = viewModel.getCurrentStreak(for: habit)

        // Then
        XCTAssertEqual(streak, 3)
    }

    func testGetCurrentStreakBrokenStreak() {
        // Given
        let habit = Habit(name: "Test Habit", category: .health)
        viewModel.addHabit(habit)

        let calendar = Calendar.current
        let today = Date()

        // Complete today and 3 days ago (not yesterday)
        viewModel.toggleHabit(habit, for: today)
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!
        viewModel.toggleHabit(habit, for: threeDaysAgo)

        // When
        let streak = viewModel.getCurrentStreak(for: habit)

        // Then
        XCTAssertEqual(streak, 1) // Only today counts
    }

    func testGetLongestStreak() {
        // Given
        let habit = Habit(name: "Test Habit", category: .health)
        viewModel.addHabit(habit)

        let calendar = Calendar.current
        let today = Date()

        // Create a streak of 5 days, starting 10 days ago
        for i in 10...14 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            viewModel.toggleHabit(habit, for: date)
        }

        // Complete today (streak of 1)
        viewModel.toggleHabit(habit, for: today)

        // When
        let longestStreak = viewModel.getLongestStreak(for: habit)

        // Then
        XCTAssertEqual(longestStreak, 5)
    }

    // MARK: - Completion Rate Tests

    func testGetCompletionRateNoLogs() {
        // Given
        let habit = Habit(name: "Test Habit", category: .health, createdAt: Date())
        viewModel.addHabit(habit)

        // When
        let rate = viewModel.getCompletionRate(for: habit)

        // Then
        XCTAssertEqual(rate, 0.0, accuracy: 0.01)
    }

    func testGetCompletionRateWithLogs() {
        // Given
        let calendar = Calendar.current
        let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: Date())!
        let habit = Habit(name: "Test Habit", category: .health, createdAt: fiveDaysAgo)
        viewModel.addHabit(habit)

        // Complete 3 out of 6 days (including today)
        for i in 0..<3 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            viewModel.toggleHabit(habit, for: date)
        }

        // When
        let rate = viewModel.getCompletionRate(for: habit)

        // Then
        // 3 completed / 6 days = 0.5
        XCTAssertEqual(rate, 0.5, accuracy: 0.01)
    }

    // MARK: - Today Progress Tests

    func testGetTodayProgressNoHabits() {
        // When
        let progress = viewModel.getTodayProgress()

        // Then
        XCTAssertEqual(progress.completed, 0)
        XCTAssertEqual(progress.total, 0)
    }

    func testGetTodayProgress() {
        // Given
        let today = Date()
        let todayWeekday = today.dayOfWeek

        let habit1 = Habit(name: "Habit 1", category: .health, targetDays: [todayWeekday])
        let habit2 = Habit(name: "Habit 2", category: .fitness, targetDays: [todayWeekday])
        let habit3 = Habit(name: "Habit 3", category: .learning, targetDays: [(todayWeekday + 1) % 7]) // Not today

        viewModel.addHabit(habit1)
        viewModel.addHabit(habit2)
        viewModel.addHabit(habit3)

        // Complete only habit1
        viewModel.toggleHabit(habit1, for: today)

        // When
        let progress = viewModel.getTodayProgress()

        // Then
        XCTAssertEqual(progress.completed, 1)
        XCTAssertEqual(progress.total, 2) // Only habit1 and habit2 are scheduled for today
    }

    // MARK: - Filtering Tests

    func testTodayHabits() {
        // Given
        let today = Date()
        let todayWeekday = today.dayOfWeek

        let todayHabit = Habit(name: "Today", category: .health, targetDays: [todayWeekday])
        let otherHabit = Habit(name: "Other Day", category: .fitness, targetDays: [(todayWeekday + 1) % 7])

        viewModel.addHabit(todayHabit)
        viewModel.addHabit(otherHabit)

        // When
        let todayHabits = viewModel.todayHabits

        // Then
        XCTAssertEqual(todayHabits.count, 1)
        XCTAssertEqual(todayHabits.first?.name, "Today")
    }

    func testHabitsForDate() {
        // Given
        let calendar = Calendar.current
        let monday = calendar.date(from: DateComponents(year: 2025, month: 12, day: 8))! // Monday
        let mondayWeekday = monday.dayOfWeek

        let mondayHabit = Habit(name: "Monday Habit", category: .health, targetDays: [mondayWeekday])
        let everydayHabit = Habit(name: "Everyday", category: .fitness, targetDays: [0, 1, 2, 3, 4, 5, 6])

        viewModel.addHabit(mondayHabit)
        viewModel.addHabit(everydayHabit)

        // When
        let habitsForMonday = viewModel.habitsForDate(monday)

        // Then
        XCTAssertEqual(habitsForMonday.count, 2)
    }

    func testHabitsByCategory() {
        // Given
        let healthHabit1 = Habit(name: "Health 1", category: .health)
        let healthHabit2 = Habit(name: "Health 2", category: .health)
        let fitnessHabit = Habit(name: "Fitness", category: .fitness)

        viewModel.addHabit(healthHabit1)
        viewModel.addHabit(healthHabit2)
        viewModel.addHabit(fitnessHabit)

        // When
        let healthHabits = viewModel.habitsByCategory(.health)

        // Then
        XCTAssertEqual(healthHabits.count, 2)
        XCTAssertTrue(healthHabits.allSatisfy { $0.category == .health })
    }

    // MARK: - Sorting Tests

    func testTodayHabitsSorting() {
        // Given
        let today = Date()
        let todayWeekday = today.dayOfWeek

        let habitA = Habit(name: "A Habit", category: .health, targetDays: [todayWeekday])
        let habitB = Habit(name: "B Habit", category: .fitness, targetDays: [todayWeekday])
        let habitC = Habit(name: "C Habit", category: .learning, targetDays: [todayWeekday])

        viewModel.addHabit(habitC)
        viewModel.addHabit(habitA)
        viewModel.addHabit(habitB)

        // Complete habitB
        viewModel.toggleHabit(habitB, for: today)

        // When
        let todayHabits = viewModel.todayHabits

        // Then
        // Incomplete habits should come first, sorted alphabetically
        XCTAssertEqual(todayHabits[0].name, "A Habit")
        XCTAssertEqual(todayHabits[1].name, "C Habit")
        XCTAssertEqual(todayHabits[2].name, "B Habit") // Completed, so last
    }
}
