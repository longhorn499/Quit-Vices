//
//  Vice.swift
//  Vices
//
//  Created by Kevin Johnson on 10/4/21.
//

import Foundation

struct Vice: Hashable, Codable {
    let name: String
    let quittingDate: Date
    /// may end up adding this.. reminds you when you come back
    let reason: String?

    init(name: String, quittingDate: Date = .todayMonthDayYear(), reason: String? = nil) {
        self.name = name
        self.quittingDate = quittingDate
        self.reason = reason
    }
}
