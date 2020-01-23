//
//  ProfileAPIClient.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 24/1/20.
//  Copyright © 2020 Phosphorous Labs. All rights reserved.
//

import Foundation

//
//  ScoreAPIClient.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 13/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import Foundation

class ProfileAPIClient {
    // MARK: Network Constants
    private static let usernameUpdateUrl: URL! = URL(string: "https://europe-west1-phosphorous.cloudfunctions.net/updateUsername")

    // MARK: Public Interface

    public static func save(username: String, andExecute callback: @escaping (_ response: String?) -> Void){
        guard let credentials = RegistrationClient.credentials() else { return callback(nil) }

        let body = [
            "deviceId": credentials.deviceId,
            "deviceSecret": credentials.deviceSecret,
            "username": username
        ]
        HTTPClient.makeRequest(url: usernameUpdateUrl, body: body, method: .post) { data in
            callback(data?["username"] as? String ?? nil)
        }
    }

    // MARK: Private helpers
    private static func convertToDictionary(text: String?) -> [String: Any]? {
        guard let text = text else { print("Could not parse response into string"); return nil }
        guard let data = text.data(using: .utf8) else { print("Error parsing response string to UTF8"); return nil }
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("Error parsing response:")
            print(error.localizedDescription)
            return nil
        }
    }

    private static func convertToJson(challengeSession: ChallengeSession) -> [String: Any ]{
        var result: [String: Any] = [:]

        let game: [String: Any] = [
            "continent": challengeSession.continent.str(),
            "livesRemaining": challengeSession.currentGameState().livesRemaining as Int,
            "lengthInMs": challengeSession.dangerousElapsedTimeInMs() as Double,
            "startedAt": Int(challengeSession.startTime!.timeIntervalSince1970 as Double * 1000)
        ]
        result["game"] = game

        let attempts: [[String: Any]] = challengeSession.attempts.map { attempt in
            return [
                "countryToFind": attempt.countryToFind.name,
                "countryGuessed": attempt.countryGuessed.name,
                "attemptedAt": Int(attempt.attemptedAt * 1000)
            ] as [String: Any]
        }
        result["attempts"] = attempts

        return result
    }
}
