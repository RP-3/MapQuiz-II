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

    private var currentSessions = [Continent: PracticeSession]()
    private var finishedSessions = [(Continent, PracticeSession)]()

    public func sessionFor(continent: Continent) -> PracticeSession {
        // if there's a current session
        if let session = self.currentSessions[continent] {
            if session.finished() { // but it's finished
                finishedSessions.append((continent, session)) // archive it
                currentSessions[continent] = PracticeSession(continent: continent) // create a new one
                return currentSessions[continent]! // return the new one
            }
            return session // it's not finished, so just return it
        }
        // there isn't a current one. Create and return a new one
        currentSessions[continent] = PracticeSession(continent: continent)
        return currentSessions[continent]!
    }
}


