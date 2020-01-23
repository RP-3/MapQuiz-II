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
    private static let usernameUpdateUrl: URL! = URL(string: "https://europe-west1-phosphorous.cloudfunctions.net/updateUsername")

    // MARK: Local Constants
    private static let deviceRegisteredKey = "deviceRegisteredKey"
    private static let deviceSecretKey = "deviceSecretKey"
    private static let defaultNameKey = "defaultNameKey"

    // MARK: Public Interface
    public static func registerDevice(){
        // registered, but no default name (old users only)
        if deviceIsRegistered() && UserDefaults.standard.string(forKey: defaultNameKey) == nil {
            let body = ["deviceId": UserDefaults.standard.string(forKey: deviceRegisteredKey)!]
            HTTPClient.makeRequest(url: deviceRegistrationUrl, body: body, method: .post) { data in
                guard let data = data else { return print("Error fetching username") }
                guard let defaultName: String = data["defaultName"] as? String else { return print("Response missing defaultName") }
                UserDefaults.standard.set(defaultName, forKey: defaultNameKey)
                print("Default name set: \(defaultName)")
            }
        }

        // old user post update. They have a name and are registered
        if RegistrationClient.deviceIsRegistered() {
            let deviceId = UserDefaults.standard.string(forKey: deviceRegisteredKey)!
            return print("Device already registered: \(deviceId)")
        }

        // new user. No name, not registered
        let body = ["deviceId": UUID().uuidString]
        HTTPClient.makeRequest(url: deviceRegistrationUrl, body: body, method: .post) { data in
            guard let data = data else { return print("Error registering device") }
            guard let deviceId: String = data["deviceId"] as? String else { return print("Response missing deviceId") }
            guard let deviceSecret: String = data["deviceSecret"] as? String else { return print("Response missing deviceSecret") }
            guard let defaultName: String = data["defaultName"] as? String else { return print("Response missing defaultName") }
            UserDefaults.standard.set(deviceId, forKey: deviceRegisteredKey)
            UserDefaults.standard.set(deviceSecret, forKey: deviceSecretKey)
            UserDefaults.standard.set(defaultName, forKey: defaultNameKey)
        }
    }

    public static func defaultName() -> String? {
        return UserDefaults.standard.string(forKey: defaultNameKey)
    }

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

