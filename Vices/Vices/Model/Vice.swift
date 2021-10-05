//
//  Vice.swift
//  Vices
//
//  Created by Kevin Johnson on 10/4/21.
//

import Foundation

struct Vice: Hashable, Codable {
    let emoji: String?
    let name: String
    /// may end up adding this.. reminds you when you come back
    let reason: String?
    let quittingDate: Date

    init(emoji: String? = nil, name: String, reason: String? = nil, quittingDate: Date = .now) {
        self.emoji = emoji
        self.name = name
        self.reason = reason
        self.quittingDate = quittingDate
    }
}
