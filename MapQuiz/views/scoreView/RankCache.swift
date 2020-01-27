//
//  RankCache.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/4/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import Foundation
class RankCache {

    public static let shared = RankCache()
    private init(){} // enforced singleton

    private(set) public var monthString = ""
    private(set) public var ranking = [(ChallengeSet, [Ranking])]()

    public func fetchLatestScores(andExecute cb: @escaping (_: Bool) -> Void ){
        ScoreAPIClient.fetchScores() { newScores, month in
            guard let newScores = newScores else { return cb(false) }
            guard let monthStr = month else { return cb(false) }

            let newRankings: [(ChallengeSet, [Ranking])] = {
                var rtn = [(ChallengeSet, [Ranking])]()
                for r in newScores {
                    if r.value.count > 0 {
                        rtn.append((r.key, r.value))
                    }
                }
                return rtn
            }()

            self.ranking = newRankings
            self.monthString = monthStr
            DispatchQueue.main.async { cb(true) }
        }
    }
}
