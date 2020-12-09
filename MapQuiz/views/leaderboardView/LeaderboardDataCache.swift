//
//  LeaderboardDataCache.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 24/1/20.
//  Copyright © 2020 Phosphorous Labs. All rights reserved.
//

import Foundation
class LeaderboardDataCache {

    public static let shared = LeaderboardDataCache()
    private init(){} // enforced singleton

    private var state: LeaderboardState? = nil

    private(set) public var requestInFlight = false
    private(set) public var data = [NamedRanking]()

    public func fetch(month: Int, year: Int, challengeSet: ChallengeSet, andExecute cb: @escaping (_: Bool) -> Void){
        guard !requestInFlight else { return cb(false) }
        requestInFlight = true
        LeaderboardAPIClient.fetchScoresFor(challengeSet: challengeSet, month: month, year: year, minPosition: 0) { rankings in
            self.requestInFlight = false
            guard let rankings = rankings else { return cb(false) }
            let newState = LeaderboardState(month: month, year: year, offset: 0, challengeSet: challengeSet)
            self.state = newState
            self.data = rankings
            return DispatchQueue.main.async { cb(true) }
        }
    }

    public func fetchNextPage(andExecute cb: @escaping (_: Bool) -> Void){
        guard !requestInFlight else { return cb(false) }
        guard let state = state else { return cb(false) }
        requestInFlight = true
        LeaderboardAPIClient.fetchScoresFor(
            challengeSet: state.challengeSet,
            month: state.month,
            year: state.year,
            minPosition: state.offset + 20
        ) { rankings in
            self.requestInFlight = false
            guard let rankings = rankings, rankings.count > 0 else { return cb(false) }
            let newState = LeaderboardState(month: state.month, year: state.year, offset: state.offset+rankings.count, challengeSet: state.challengeSet)
            self.state = newState
            self.data.append(contentsOf: rankings)
            return DispatchQueue.main.async { cb(true) }
        }
    }
}

fileprivate struct LeaderboardState {
    let month: Int
    let year: Int
    let offset: Int
    let challengeSet: ChallengeSet

    func differsInOffsetOnly(from other: LeaderboardState) -> Int? {
        if  self.month == other.month &&
            self.year == other.year &&
            self.challengeSet == other.challengeSet &&
            self.offset != other.offset
        {
            return abs(self.offset - other.offset)
        }
        return nil
    }
}
