//
//  ChallengeSessionRegistry.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import Foundation

class ChallengeSessionRegistry {

    public static let shared = ChallengeSessionRegistry()
    private var finishedSessions = [ChallengeSession]()
    private var timer: Timer?
    private var requestInFlight = false

    private init(){ // private to enforce singleton
        self.timer = Timer.scheduledTimer(
            timeInterval: 30.0,
            target: self,
            selector: #selector(self.uploadSessions),
            userInfo: nil,
            repeats: true
        )
    }

    deinit { self.timer?.invalidate() }

    public func enqueue(session: ChallengeSession){
        guard session.currentGameState().livesRemaining > 0 && session.remainingCountries().count == 0 else { return }
        finishedSessions.append(session)
        self.uploadSessions()
    }

    @objc func uploadSessions(){
        guard !requestInFlight else { return }
        guard let session = finishedSessions.last else { return }

        requestInFlight = true

        ScoreAPIClient.save(challengeSession: session, andExecute: { success in
            self.requestInFlight = false
            guard success else { return }
            if self.finishedSessions.isEmpty {
                print("Warning: ChallengeSessionRegistry attempted to remove element from empty array.")
            } else {
                self.finishedSessions.removeLast()
                self.uploadSessions()
            }
        })
    }

}
