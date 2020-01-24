//
//  Ranking.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/4/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//
import Foundation

struct Ranking {
    let livesRemaining: Int
    let lengthInMs: Int
    let rank: Int
    let total: Int
    let startedAt: Date

    static func from(dict: [String: Any]) -> Ranking? {
        guard let livesRemaining = dict["livesRemaining"] as? Int else { return nil }
        guard let lengthInMs = dict["lengthInMs"] as? Int else { return nil }
        guard let rank = dict["rank"] as? Int else { return nil }
        guard let dateString = dict["startedAt"] as? String else { return nil }
        guard let total = dict["total"] as? Int else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let startedAt = dateFormatter.date(from: dateString) else { return nil }

        return Ranking(
            livesRemaining: livesRemaining,
            lengthInMs: lengthInMs,
            rank: rank,
            total: total,
            startedAt: startedAt
        )
    }
}

struct NamedRanking {
    let livesRemaining: Int
    let lengthInMs: Int
    let rank: Int
    let startedAt: Date
    let name: String

    static func from(dict: [String: Any]) -> NamedRanking? {
        guard let livesRemaining = dict["livesRemaining"] as? Int else { return nil }
        guard let lengthInMs = dict["lengthInMs"] as? Int else { return nil }
        guard let rank = dict["rank"] as? Int else { return nil }
        guard let dateString = dict["startedAt"] as? String else { return nil }
        guard let name = dict["name"] as? String else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
        guard let startedAt = dateFormatter.date(from: dateString) else { return nil }

        return NamedRanking(
            livesRemaining: livesRemaining,
            lengthInMs: lengthInMs,
            rank: rank,
            startedAt: startedAt,
            name: name
        )
    }
}
