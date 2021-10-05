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
    let quittingDate: Date

    init(emoji: String? = nil, name: String, quittingDate: Date = .now) {
        self.emoji = emoji
        self.name = name
        self.quittingDate = quittingDate
    }
}
