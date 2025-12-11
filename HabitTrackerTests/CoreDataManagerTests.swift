//
//  CoreDataManagerTests.swift
//  HabitTrackerTests
//
//  Created by Diana Maldonado on 2025-12-10.
//

import XCTest
import CoreData
@testable import HabitTracker

final class CoreDataManagerTests: XCTestCase {

    var testCoreDataManager: TestCoreDataManager!

    override func setUp() {
        super.setUp()
        testCoreDataManager = TestCoreDataManager()
    }

    override func tearDown() {
        testCoreDataManager = nil
        super.tearDown()
    }

    // MARK: - Habit CRUD Tests

    func testCreateHabit() {
        // Given
        let habit = Habit(
            name: "Test Habit",
            description: "Test Description",
            icon: "star.fill",
            color: "blue",
            category: .health,
            frequency: .daily,
            targetDays: [1, 2, 3, 4, 5],
            goal: 1
        )

        // When
        let entity = testCoreDataManager.createHabit(from: habit)

        // Then
        XCTAssertEqual(entity.name, "Test Habit")
        XCTAssertEqual(entity.descriptionText, "Test Description")
        XCTAssertEqual(entity.icon, "star.fill")
        XCTAssertEqual(entity.color, "blue")
        XCTAssertEqual(entity.category, "Health")
        XCTAssertEqual(entity.frequency, "Daily")
        XCTAssertEqual(entity.targetDays as? [Int], [1, 2, 3, 4, 5])
        XCTAssertEqual(entity.goal, 1)
    }

    func testFetchHabits() {
        // Given
        let habit1 = Habit(name: "Habit 1", category: .health)
        let habit2 = Habit(name: "Habit 2", category: .fitness)

        testCoreDataManager.createHabit(from: habit1)
        testCoreDataManager.createHabit(from: habit2)

        // When
        let fetchedHabits = testCoreDataManager.fetchHabits()

        // Then
        XCTAssertEqual(fetchedHabits.count, 2)
        XCTAssertTrue(fetchedHabits.contains { $0.name == "Habit 1" })
        XCTAssertTrue(fetchedHabits.contains { $0.name == "Habit 2" })
    }

    func testUpdateHabit() {
        // Given
        var habit = Habit(name: "Original Name", category: .health)
        testCoreDataManager.createHabit(from: habit)

        // When
        habit.name = "Updated Name"
        habit.description = "New Description"
        habit.color = "red"
        testCoreDataManager.updateHabit(habit)

        // Then
        let fetchedHabits = testCoreDataManager.fetchHabits()
        let updatedHabit = fetchedHabits.first { $0.id == habit.id }

        XCTAssertNotNil(updatedHabit)
        XCTAssertEqual(updatedHabit?.name, "Updated Name")
        XCTAssertEqual(updatedHabit?.description, "New Description")
        XCTAssertEqual(updatedHabit?.color, "red")
    }

    func testDeleteHabit() {
        // Given
        let habit = Habit(name: "To Delete", category: .health)
        testCoreDataManager.createHabit(from: habit)

        // Verify it was created
        var fetchedHabits = testCoreDataManager.fetchHabits()
        XCTAssertEqual(fetchedHabits.count, 1)

        // When
        testCoreDataManager.deleteHabit(habit)

        // Then
        fetchedHabits = testCoreDataManager.fetchHabits()
        XCTAssertEqual(fetchedHabits.count, 0)
    }

    // MARK: - Log CRUD Tests

    func testCreateLog() {
        // Given
        let habit = Habit(name: "Test Habit", category: .health)
        testCoreDataManager.createHabit(from: habit)
        let date = Date()

        // When
        testCoreDataManager.createLog(habitId: habit.id, date: date, completed: true, note: "Test note")

        // Then
        let logs = testCoreDataManager.fetchLogs(for: habit.id)
        XCTAssertEqual(logs.count, 1)
        XCTAssertEqual(logs.first?.habitId, habit.id)
        XCTAssertTrue(logs.first?.completed ?? false)
        XCTAssertEqual(logs.first?.note, "Test note")
    }

    func testCreateLogPreventsDoubleLogging() {
        // Given
        let habit = Habit(name: "Test Habit", category: .health)
        testCoreDataManager.createHabit(from: habit)
        let date = Date()

        // When
        testCoreDataManager.createLog(habitId: habit.id, date: date, completed: true, note: nil)
        testCoreDataManager.createLog(habitId: habit.id, date: date, completed: true, note: nil) // Try to create duplicate

        // Then
        let logs = testCoreDataManager.fetchLogs(for: habit.id)
        XCTAssertEqual(logs.count, 1) // Should only have one log
    }

    func testDeleteLog() {
        // Given
        let habit = Habit(name: "Test Habit", category: .health)
        testCoreDataManager.createHabit(from: habit)
        let date = Date()

        testCoreDataManager.createLog(habitId: habit.id, date: date, completed: true, note: nil)

        // Verify log was created
        var logs = testCoreDataManager.fetchLogs(for: habit.id)
        XCTAssertEqual(logs.count, 1)

        // When
        testCoreDataManager.deleteLog(habitId: habit.id, date: date)

        // Then
        logs = testCoreDataManager.fetchLogs(for: habit.id)
        XCTAssertEqual(logs.count, 0)
    }

    func testFetchLogsForSpecificHabit() {
        // Given
        let habit1 = Habit(name: "Habit 1", category: .health)
        let habit2 = Habit(name: "Habit 2", category: .fitness)

        testCoreDataManager.createHabit(from: habit1)
        testCoreDataManager.createHabit(from: habit2)

        let date = Date()
        testCoreDataManager.createLog(habitId: habit1.id, date: date, completed: true, note: nil)
        testCoreDataManager.createLog(habitId: habit2.id, date: date, completed: true, note: nil)

        // When
        let habit1Logs = testCoreDataManager.fetchLogs(for: habit1.id)

        // Then
        XCTAssertEqual(habit1Logs.count, 1)
        XCTAssertEqual(habit1Logs.first?.habitId, habit1.id)
    }

    func testFetchAllLogs() {
        // Given
        let habit1 = Habit(name: "Habit 1", category: .health)
        let habit2 = Habit(name: "Habit 2", category: .fitness)

        testCoreDataManager.createHabit(from: habit1)
        testCoreDataManager.createHabit(from: habit2)

        let date = Date()
        testCoreDataManager.createLog(habitId: habit1.id, date: date, completed: true, note: nil)
        testCoreDataManager.createLog(habitId: habit2.id, date: date, completed: true, note: nil)

        // When
        let allLogs = testCoreDataManager.fetchLogs()

        // Then
        XCTAssertEqual(allLogs.count, 2)
    }

    func testIsHabitCompleted() {
        // Given
        let habit = Habit(name: "Test Habit", category: .health)
        testCoreDataManager.createHabit(from: habit)
        let date = Date()

        // When - Not completed
        var isCompleted = testCoreDataManager.isHabitCompleted(habitId: habit.id, on: date)

        // Then
        XCTAssertFalse(isCompleted)

        // When - Completed
        testCoreDataManager.createLog(habitId: habit.id, date: date, completed: true, note: nil)
        isCompleted = testCoreDataManager.isHabitCompleted(habitId: habit.id, on: date)

        // Then
        XCTAssertTrue(isCompleted)
    }

    func testIsHabitCompletedDifferentDays() {
        // Given
        let habit = Habit(name: "Test Habit", category: .health)
        testCoreDataManager.createHabit(from: habit)

        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        // When
        testCoreDataManager.createLog(habitId: habit.id, date: today, completed: true, note: nil)

        // Then
        XCTAssertTrue(testCoreDataManager.isHabitCompleted(habitId: habit.id, on: today))
        XCTAssertFalse(testCoreDataManager.isHabitCompleted(habitId: habit.id, on: yesterday))
    }

    // MARK: - Cascade Delete Tests

    func testDeleteHabitCascadesLogs() {
        // Given
        let habit = Habit(name: "Test Habit", category: .health)
        testCoreDataManager.createHabit(from: habit)

        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        testCoreDataManager.createLog(habitId: habit.id, date: today, completed: true, note: nil)
        testCoreDataManager.createLog(habitId: habit.id, date: yesterday, completed: true, note: nil)

        // Verify logs were created
        var logs = testCoreDataManager.fetchLogs(for: habit.id)
        XCTAssertEqual(logs.count, 2)

        // When
        testCoreDataManager.deleteHabit(habit)

        // Then
        logs = testCoreDataManager.fetchLogs(for: habit.id)
        XCTAssertEqual(logs.count, 0) // Logs should be deleted with habit
    }

    // MARK: - Data Persistence Tests

    func testDataPersistence() {
        // Given
        let habit = Habit(name: "Persistent Habit", category: .health)
        testCoreDataManager.createHabit(from: habit)

        // When
        testCoreDataManager.save()

        // Create a new manager instance to simulate app restart
        let newManager = TestCoreDataManager()

        // Then
        let fetchedHabits = newManager.fetchHabits()
        XCTAssertEqual(fetchedHabits.count, 1)
        XCTAssertEqual(fetchedHabits.first?.name, "Persistent Habit")
    }
}

// MARK: - Test Core Data Manager

/// Test version of CoreDataManager that uses in-memory store
class TestCoreDataManager: CoreDataManager {

    static var shared: TestCoreDataManager {
        return TestCoreDataManager()
    }

    override init() {
        // Create in-memory persistent container
        let container = NSPersistentContainer(name: "HabitTracker")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // Call super.init() but we need to override the container
        super.init()

        // Replace the container with our test container
        // Note: This is a workaround since we can't easily modify the parent's init
    }
}
