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
        let start = calendar.startOfDay(for: self)
        return calendar.date(byAdding: .day, value: -days, to: start) ?? start
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }

    var dayOfWeekIndex: Int {
        Calendar.current.component(.weekday, from: self) - 1
    }

    var dayOfWeek: Int { dayOfWeekIndex }
    
    func startOfWeekMonday(calendar: Calendar = .current) -> Date {
            var cal = calendar
            cal.firstWeekday = 2 // Monday

            let start = cal.dateInterval(of: .weekOfYear, for: self)?.start ?? self
            return cal.startOfDay(for: start)
        }
}
