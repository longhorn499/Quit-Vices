//
//  Icons.swift
//  Vices
//
//  Created by Kevin Johnson on 2/23/22.
//

import Foundation

enum Icons: Int, CaseIterable {
    case noé
    case vices

    var title: String {
        switch self {
        case .noé:
            return "Noé"
        case .vices:
            return "Vices"
        }
    }

    var imageAssetName: String {
        switch self {
        case .noé:
            return "Icon-1"
        case .vices:
            return "Icon-2"
        }
    }

    init(name: String?) {
        switch name {
        case "Drawing":
            self = .vices
        default:
            self = .noé
        }
    }
}
