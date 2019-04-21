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
        if elapsedSeconds < (5 * 60) {
            StoreReviewController.requestReview()
        }
        else { // else if they're regulars
            let appOpenCount = UserDefaults.standard.integer(forKey: StoreReviewController.APP_OPEN_COUNT)
            switch appOpenCount {
            case 5:
                StoreReviewController.requestReview()
            case _ where appOpenCount%10 == 0 :
                StoreReviewController.requestReview()
            default:
                print("App run count is : \(appOpenCount)")
                break;
            }
        }
    }

    private static func requestReview() {
        // this will not be shown everytime. Apple has some internal logic that decides
        guard #available(iOS 10.3, *) else { return }
        SKStoreReviewController.requestReview()
    }
}

