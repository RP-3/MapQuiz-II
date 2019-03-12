//
//  ChallengeSessionRegistry.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

class ChallengeSessionRegistry {

    public static let shared = ChallengeSessionRegistry()
    private init(){} // enforced singleton

    private var finishedSessions = [(Continent, ChallengeSession)]()

    /*
     TODO: Add a method to finish a session, following which attempt
     to upload the attempts. If that fails, retry on a regular
     schedule. When we eventually succeed, clear the sessions out
     of the finishedSessions array.
     */

}
