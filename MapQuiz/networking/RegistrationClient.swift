//
//  RegistrationClient.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 24/1/20.
//  Copyright © 2020 Phosphorous Labs. All rights reserved.
//

import Foundation

class RegistrationClient {
    // MARK: Network Constants
    private static let deviceRegistrationUrl: URL! = URL(string: "https://europe-west1-phosphorous.cloudfunctions.net/mapquiz-register-device")

    // MARK: Local Constants
    private static let deviceRegisteredKey = "deviceRegisteredKey"
    private static let deviceSecretKey = "deviceSecretKey"

    // MARK: Public Interface
    public static func registerDevice(){
        if RegistrationClient.deviceIsRegistered() { return print("Device already registered") }
        let body = ["deviceId": UUID().uuidString]
        HTTPClient.makeRequest(url: deviceRegistrationUrl, body: body, method: .post) { data in
            guard let data = data else { return print("Error registering device") }
            guard let deviceId: String = data["deviceId"] as? String else { return print("Response missing deviceId") }
            guard let deviceSecret: String = data["deviceSecret"] as? String else { return print("Response missing deviceSecret") }
            UserDefaults.standard.set(deviceId, forKey: deviceRegisteredKey)
            UserDefaults.standard.set(deviceSecret, forKey: deviceSecretKey)
        }
    }

    public static func deviceIsRegistered() -> Bool {
        guard UserDefaults.standard.string(forKey: deviceRegisteredKey) != nil else { return false }
        guard UserDefaults.standard.string(forKey: deviceSecretKey) != nil else { return false }
        return true
    }

    public static func credentials() -> RegistrationCredentials? {
        guard deviceIsRegistered() else { return nil }
        return RegistrationCredentials(
            deviceId: UserDefaults.standard.string(forKey: deviceRegisteredKey)!,
            deviceSecret: UserDefaults.standard.string(forKey: deviceSecretKey)!
        )
    }
}

struct RegistrationCredentials {
    let deviceId: String
    let deviceSecret: String
}

