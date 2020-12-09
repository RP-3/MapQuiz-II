//
//  PracticeSessionRegistry.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

class PracticeSessionRegistry {

    public static let shared = PracticeSessionRegistry()
    private init(){} // enforced singleton

    private var currentSessions = [ChallengeSet: PracticeSession]()
    private var finishedSessions = [(ChallengeSet, PracticeSession)]()

    public func sessionFor(challengeSet: ChallengeSet) -> PracticeSession {
        // if there's a current session
        if let session = self.currentSessions[challengeSet] {
            if session.finished() { // but it's finished
                finishedSessions.append((challengeSet, session)) // archive it
                currentSessions[challengeSet] = PracticeSession(challengeSet: challengeSet) // create a new one
                return currentSessions[challengeSet]! // return the new one
            }
            return session // it's not finished, so just return it
        }
        // there isn't a current one. Create and return a new one
        currentSessions[challengeSet] = PracticeSession(challengeSet: challengeSet)
        return currentSessions[challengeSet]!
    }
}


