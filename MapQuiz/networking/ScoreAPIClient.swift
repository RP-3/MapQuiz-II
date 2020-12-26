//
//  ScoreAPIClient.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 13/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import Foundation

class ScoreAPIClient {
    // MARK: Network Constants
    private static let saveChallengeSessionUrl: URL! = URL(string: "https://europe-west1-phosphorous.cloudfunctions.net/mapquiz-save-game")
    private static let fetchGameScoresUrl: URL! = URL(string: "https://europe-west1-phosphorous.cloudfunctions.net/mapquiz-v3-game-scores")

    // MARK: Public Interface
    public static func fetchScores(andExecute cb: @escaping (_: [ChallengeSet: [Ranking]]?, _: String?) -> Void ){
        guard let credentials = RegistrationClient.credentials() else { return cb(nil, nil) }

        let body = ["deviceId": credentials.deviceId, "deviceSecret": credentials.deviceSecret ]
        HTTPClient.makeRequest(url: fetchGameScoresUrl, body: body, method: .post) { dict in
            guard let dict = dict else { return cb(nil, nil) }
            guard let month = dict["month"] as? String else { return cb(nil, nil) }
            guard let rankings = dict["rankings"] as? [[String: Any]] else { return cb(nil, nil) }

            var rtn: [ChallengeSet: [Ranking]] = [:]
            for ranking in rankings {
                guard let challengeSet = ChallengeSets.from(slug: (ranking["code"] as? String ?? "")) else {
                    print("WARNING: Could not parse ChallengeSet from: \(String(describing: ranking["code"] as? String))")
                    continue
                }
                var scores: [Ranking] = []
                guard let dictScores = ranking["scores"] as? [[String: Any]] else {
                    print("WARNING: Could not parse scores from: \(String(describing: ranking["scores"] as? [[String: Any]]))")
                    continue
                }
                for dictScore in dictScores {
                    guard let score = Ranking.from(dict: dictScore) else {
                        print("WARNING: Could not parse ranking from \(dictScore)")
                        continue
                    }
                    scores.append(score)
                }
                rtn[challengeSet] = scores
            }
            return cb(rtn, month)
        }
    }

    public static func save(challengeSession: ChallengeSession, andExecute callback: @escaping (_ success: Bool) -> Void){
        guard let credentials = RegistrationClient.credentials() else { RegistrationClient.registerDevice(); return callback(false) }
        var body = convertToJson(challengeSession: challengeSession)
        body["deviceId"] = credentials.deviceId
        body["deviceSecret"] = credentials.deviceSecret
        HTTPClient.makeRequest(url: saveChallengeSessionUrl, body: body, method: .post) { callback($0 != nil ? true : false) }
    }

    // MARK: Private helpers
    private static func convertToJson(challengeSession: ChallengeSession) -> [String: Any ]{
        var result: [String: Any] = [:]

        let game: [String: Any] = [
            "continent": challengeSession.challengeSet.slug,
            "livesRemaining": challengeSession.currentGameState().livesRemaining as Int,
            "lengthInMs": challengeSession.dangerousElapsedTimeInMs() as Double,
            "startedAt": Int(challengeSession.startTime!.timeIntervalSince1970 as Double * 1000)
        ]
        result["game"] = game

        let attempts: [[String: Any]] = challengeSession.attempts.map { attempt in
            return [
                "countryToFind": attempt.itemToFind.name,
                "countryGuessed": attempt.itemGuessed.name,
                "attemptedAt": Int(attempt.attemptedAt * 1000)
            ] as [String: Any]
        }
        result["attempts"] = attempts

        return result
    }
}
