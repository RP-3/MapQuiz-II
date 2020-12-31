//
//  RankCache.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/4/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import Foundation
/*
 RankRache stores the latest rankings for all challengesets you've completed
 for viewing in the "my Top Scores" tab of the leaderbord. It also includes
 a simple persitent getter-setter mechanism to store the summary of the most
 recently successfully completed challenge session. 
 */
class RankCache {
    public static let shared = RankCache()
    private init(){} // enforced singleton

    private(set) public var monthString = ""
    private(set) public var ranking = [(ChallengeSet, [Ranking])]()

    public func fetchLatestScores(andExecute cb: @escaping (_: Bool) -> Void ){
        ScoreAPIClient.fetchScores() { newScores, month in
            guard let newScores = newScores else { return DispatchQueue.main.async { cb(false) } }
            guard let monthStr = month else { return DispatchQueue.main.async { cb(false) } }

            let newRankings: [(ChallengeSet, [Ranking])] = {
                var rtn = [(ChallengeSet, [Ranking])]()
                for r in newScores {
                    if r.value.count > 0 {
                        rtn.append((r.key, r.value))
                    }
                }
                return rtn
            }()

            self.ranking = newRankings.sorted(by: { (item1: (ChallengeSet, [Ranking]), item2: (ChallengeSet, [Ranking])) -> Bool in
                return item1.0.title < item2.0.title
            })
            self.monthString = monthStr
            DispatchQueue.main.async { cb(true) }
        }
    }

    public func score(for challengeSet: ChallengeSet) -> Ranking? {
        for tuple in self.ranking {
            if tuple.0 == challengeSet { return tuple.1.first }
        }
        return nil
    }

    public func saveSummary(for challengeSession: ChallengeSession){
        guard challengeSession.completed() else { return }
        let (lengthKey, livesKey) = self.mostRecentGameSummaryKeys(for: challengeSession.challengeSet)
        let summary = challengeSession.summary()
        UserDefaults.standard.set(summary.lengthInMs, forKey: lengthKey)
        UserDefaults.standard.set(summary.livesRemaining, forKey: livesKey)
    }

    public func fetchGameSummary(for challengeSet: ChallengeSet) -> ChallengeSessionSummary? {
        let (lengthKey, livesKey) = self.mostRecentGameSummaryKeys(for: challengeSet)
        let length = UserDefaults.standard.integer(forKey: lengthKey)
        let lives = UserDefaults.standard.integer(forKey: livesKey)
        if length == 0 || lives == 0 { return nil }
        return ChallengeSessionSummary(livesRemaining: lives, lengthInMs: length)
    }

    private func mostRecentGameSummaryKeys(for challengeSet: ChallengeSet) -> (String, String) {
        return ("most_recent_game_timing_\(challengeSet.slug)", "most_recent_game_lives_\(challengeSet.slug)")
    }
}
