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
    private static let SessionUrl: URL! = URL(string: "http://52.53.164.87/api/users/games")
    private static let deviceRegistrationUrl: URL! = URL(string: "https://us-central1-phosphorous.cloudfunctions.net/mapquiz-register-device")
    private static let saveChallengeSessionUrl: URL! = URL(string: "https://us-central1-phosphorous.cloudfunctions.net/mapquiz-save-game")

    // MARK: Local Constants
    private static let deviceRegisteredKey = "deviceRegisteredKey"
    private static let deviceSecretKey = "deviceSecretKey"

    private static func deviceIsRegistered() -> Bool {
        guard UserDefaults.standard.string(forKey: deviceRegisteredKey) != nil else { return false }
        guard UserDefaults.standard.string(forKey: deviceSecretKey) != nil else { return false }
        return true
    }

    public static func registerDevice(){
        if ScoreAPIClient.deviceIsRegistered() { return print("Device already registered") }
        let body = ["deviceId": UUID().uuidString]
        ScoreAPIClient.makeRequest(url: deviceRegistrationUrl, body: body, method: .post) { data in
            guard let data = data else { return print("Error registering device") }
            guard let deviceId: String = data["deviceId"] as? String else { return print("Response missing deviceId") }
            guard let deviceSecret: String = data["deviceSecret"] as? String else { return print("Response missing deviceSecret") }
            UserDefaults.standard.set(deviceId, forKey: deviceRegisteredKey)
            UserDefaults.standard.set(deviceSecret, forKey: deviceSecretKey)
        }
    }

    public static func save(challengeSession: ChallengeSession, andExecute callback: @escaping (_ success: Bool) -> Void){
        guard ScoreAPIClient.deviceIsRegistered() else {
            ScoreAPIClient.registerDevice()
            return callback(false)
        }

        var body = ScoreAPIClient.convertToJson(challengeSession: challengeSession)
        body["deviceId"] = UserDefaults.standard.string(forKey: deviceRegisteredKey)!
        body["deviceSecret"] = UserDefaults.standard.string(forKey: deviceSecretKey)!
        makeRequest(url: ScoreAPIClient.saveChallengeSessionUrl, body: body, method: .post) { callback($0 != nil ? true : false) }
    }

    // MARK: Private helpers
    private static func makeRequest(url: URL, body: [String: Any], method: HttpMethod, completion: @escaping (_ data: [String: Any]?) -> Void){
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = method.rawValue

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            completion(nil)
        }

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in

            if error != nil {
                print(error?.localizedDescription as Any)
                return completion(nil)
            }

            if let resp = response as? HTTPURLResponse {
                if resp.statusCode >= 400 {
                    if let data = data {
                        if let errorMessage = String(bytes: data, encoding: String.Encoding.utf8) {
                            print(errorMessage)
                        }else{
                            print("Failed to parse data in 400 response")
                        }
                    }else{
                        print("Received 400 with no data from server")
                    }
                    return completion(nil)
                }else{
                    if let data = data {
                        let str = String(bytes: data, encoding: String.Encoding.utf8)
                        return completion(ScoreAPIClient.convertToDictionary(text: str))
                    }else {
                        print("Recieved 200-399 response but with no data")
                        return completion(nil)
                    }

                }
            }else{
                print("Failed to parse server response")
                return completion(nil)
            }
        })
        task.resume()
    }

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


fileprivate enum HttpMethod: String {
    case put = "PUT"
    case post = "POST"
}
