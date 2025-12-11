//
//  HabitTrackerTests.swift
//  HabitTrackerTests
//
//  Created by Diana Maldonado on 2025-12-10.
//

import Testing

/// Main test suite for HabitTracker app
///
/// This file serves as the entry point for the test suite.
/// Individual test files:
/// - HabitModelTests.swift: Tests for data models (Habit, HabitLog, Date extensions)
/// - HabitViewModelTests.swift: Tests for ViewModel business logic
/// - CoreDataManagerTests.swift: Tests for Core Data persistence layer
struct HabitTrackerTests {

    @Test func appTestSuiteAvailable() async throws {
        // This test ensures the test suite is properly configured
        #expect(true)
    }

}
