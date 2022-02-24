//
//  UserReviews.swift
//  Vices
//
//  Created by Kevin Johnson on 12/13/21.
//

import StoreKit

struct UserReviews {
    private static let key = "key_action_count"
    private static let triggersReviewCount = 20

    static func incrementReviewActionCount(defaults: UserDefaults = .standard) {
        var count = defaults.integer(forKey: key)
        count += 1
        if count == triggersReviewCount {
            requestReview()
            defaults.set(0, forKey: key)
        } else {
            defaults.set(count, forKey: key)
        }
    }

    /// based on SO post.. hm
    private static func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
