//
//  ChallengeSessionAttempt.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/4/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import Foundation

struct ChallengeSessionAttempt {
    let itemToFind: BoundedItem
    let itemGuessed: BoundedItem
    let attemptedAt: TimeInterval
}
