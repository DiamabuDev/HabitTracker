//
//  Date.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-12.
//

import Foundation

extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: comps) ?? self
    }
    
    func offsetBy(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    func daysAgo(_ days: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: -days, to: self) ?? self
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    // Sunday = 0 ... Saturday = 6
    var dayOfWeekIndex: Int {
        Calendar.current.component(.weekday, from: self) - 1
    }
    
    // Alias used throughout the project/tests
    var dayOfWeek: Int {
        dayOfWeekIndex
    }
}
