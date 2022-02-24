//
//  Vice.swift
//  Vices
//
//  Created by Kevin Johnson on 10/4/21.
//

import Foundation

struct Vice: Hashable, Codable {
    var name: String
    var quittingDate: Date
    var reason: String?

    init(name: String, quittingDate: Date = .todayMonthDayYear(), reason: String?) {
        self.name = name
        self.quittingDate = quittingDate
        self.reason = reason
    }
}
