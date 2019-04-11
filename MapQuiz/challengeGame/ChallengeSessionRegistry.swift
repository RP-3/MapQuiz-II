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
        finishedSessions.append(session)
        self.uploadSessions()
    }

    @objc func uploadSessions(){
        if let session = finishedSessions.last {
            ScoreAPIClient.save(challengeSession: session, andExecute: { success in
                guard success else { return }
                self.finishedSessions.removeLast()
                self.uploadSessions()
            })
        }
    }

}
