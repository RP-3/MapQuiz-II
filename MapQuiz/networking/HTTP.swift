//
//  HTTP.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 24/1/20.
//  Copyright © 2020 Phosphorous Labs. All rights reserved.
//

import Foundation

class HTTPClient {

    public static func makeRequest(url: URL, body: [String: Any], method: HttpMethod, completion: @escaping (_ data: [String: Any]?) -> Void){
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

            DispatchQueue.main.async {
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
                            let result = HTTPClient.convertToDictionary(text: str)
                            return completion(result)
                        }else {
                            print("Recieved 200-399 response but with no data")
                            return completion(nil)
                        }

                    }
                }else{
                    print("Failed to parse server response")
                    return completion(nil)
                }
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
}


enum HttpMethod: String {
    case put = "PUT"
    case post = "POST"
}

