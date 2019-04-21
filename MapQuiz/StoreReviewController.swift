//
//  StoreReviewController.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 22/4/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import Foundation
import StoreKit

class StoreReviewController {
    private static let APP_OPEN_COUNT = "APP_OPEN_COUNT"
    private static let LAST_GAME_TIMESTAMP = "LAST_GAME_TIMESTAMP"

    static func markChallengeCompleted(){
        let now = Date().timeIntervalSince1970
        UserDefaults.standard.set(now, forKey: StoreReviewController.LAST_GAME_TIMESTAMP)
    }

    static func incrementAppOpenedCount() { // called from appdelegate didfinishLaunchingWithOptions:
        var appOpenCount = UserDefaults.standard.integer(forKey: StoreReviewController.APP_OPEN_COUNT)
        appOpenCount += 1
        UserDefaults.standard.set(appOpenCount, forKey: StoreReviewController.APP_OPEN_COUNT)
    }

    static func safelyRequestReview() { // call this whenever appropriate
        // if they've just finished a challenge
        let challengeTime = UserDefaults.standard.double(forKey: StoreReviewController.LAST_GAME_TIMESTAMP)
        let elapsedSeconds = Date().timeIntervalSince(Date(timeIntervalSince1970: challengeTime))
        let appOpenCount = UserDefaults.standard.integer(forKey: StoreReviewController.APP_OPEN_COUNT)
        if elapsedSeconds < 90 && appOpenCount%5 == 0 { StoreReviewController.requestReview() }
    }

    private static func requestReview() {
        // this will not be shown everytime. Apple has some internal logic that decides
        guard #available(iOS 10.3, *) else { return }
        SKStoreReviewController.requestReview()
    }
}

