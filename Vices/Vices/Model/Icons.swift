//
//  Icons.swift
//  Vices
//
//  Created by Kevin Johnson on 2/23/22.
//

import Foundation

enum Icons: Int, CaseIterable {
    case vices
    case noé

    var title: String {
        switch self {
        case .vices:
            return "Vices"
        case .noé:
            return "Noé"
        }
    }

    var imageAssetName: String {
        switch self {
        case .vices:
            return "Icon-1"
        case .noé:
            return "Icon-2"
        }
    }

    init(name: String?) {
        switch name {
        case "Noe":
            self = .noé
        default:
            self = .vices
        }
    }
}
