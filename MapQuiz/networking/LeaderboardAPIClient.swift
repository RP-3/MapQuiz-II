//
//  LeaderboardAPIClient.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 24/1/20.
//  Copyright © 2020 Phosphorous Labs. All rights reserved.
//

import Foundation

class LeaderboardAPIClient {
    // MARK: Network Constants
    private static let leaderboardUrl: URL! = URL(string: "https://europe-west1-phosphorous.cloudfunctions.net/leaderboard")

    // MARK: Public Interface
    public static func fetchScoresFor(
        continent: ChallengeSet,
        month: Int,
        year: Int,
        minPosition: Int,
        andExecute cb: @escaping (_: [NamedRanking]?) -> Void
    ){
        let body: [String: Any] = [
            "continent": continent.rawValue,
            "month": month,
            "year": year,
            "minPosition": minPosition
        ]

        HTTPClient.makeRequest(url: leaderboardUrl, body: body, method: .post) { resultObj in
            guard let resultObj = resultObj else { return cb(nil) }
            guard let list = resultObj["results"] as? [[String: Any]] else { return cb(nil) }
            let results: [NamedRanking] = list.compactMap { dict in
                let row = NamedRanking.from(dict: dict)
                if row == nil{
                    print("Warning: Discarding the following row due to a parse error")
                    print(dict)
                }
                return row
            }
            if(results.count < list.count) {
                print("Warning: discarded \(list.count - results.count) NamedRanking due to parse errors.")
            }
            return cb(results)
        }
    }
}
