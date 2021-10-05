//
//  UIDate+Extensions.swift
//  Vices
//
//  Created by Kevin Johnson on 10/5/21.
//

import Foundation

extension Date {
    static func todayMonthDayYear(calendar: Calendar = .current) -> Date {
        let comp = calendar.dateComponents([.year, .month, .day], from: .now)
        return monthDayYearDate(month: comp.month!, day: comp.day!, year: comp.year!)
    }

    static func monthDayYearDate(month: Int, day: Int, year: Int, calendar: Calendar = .current) -> Date {
        let comp = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: comp)!
    }

    func daysFromToday(calendar: Calendar = .current) -> Int {
        return calendar.dateComponents([.day], from: .todayMonthDayYear(), to: self).day!
    }
}
