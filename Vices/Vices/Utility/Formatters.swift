//
//  DateFormatters.swift
//  Vices
//
//  Created by Kevin Johnson on 10/6/21.
//

import Foundation

struct Formatters {
    static let relative = RelativeDateTimeFormatter()

    static func quittingDay(_ day: Date) -> String {
        let days = day.daysFromToday()
        if days == 0 {
            return  "Today" // there is a formatter for this?
        } else {
            return relative.localizedString(from: DateComponents(day: days))
        }
    }
}
