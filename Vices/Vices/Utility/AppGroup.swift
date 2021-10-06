//
//  AppGroup.swift
//  Vices
//
//  Created by Kevin Johnson on 10/6/21.
//

import Foundation

// https://useyourloaf.com/blog/sharing-data-with-a-widget/
enum AppGroup: String {
  case todos = "group.com.frr.todos"

    var containerURL: URL {
        switch self {
        case .todos:
            return FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: rawValue
            )!
        }
    }
}
