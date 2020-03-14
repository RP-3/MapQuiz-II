//
//  Ranking.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/4/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//
import Foundation

private func format(milliseconds: Int) -> String{
    let minutes = (milliseconds / 1000) / 60
    let seconds = (milliseconds / 1000) - (minutes * 60)
    let remainingMilliseconds = milliseconds % 1000
    let minuteString: String = {
        if minutes == 0 { return "00" }
        if minutes < 10 { return "0\(String(minutes))"}
        return String(minutes)
    }()
    let secondString: String = {
        if seconds == 0 { return "00" }
        if seconds < 10 { return "0\(String(seconds) )"}
        return String(seconds)
    }()
    let msString: String = {
        if remainingMilliseconds == 0 { return "000" }
        if remainingMilliseconds < 10 { return "00\(String(remainingMilliseconds))"}
        if remainingMilliseconds < 100 { return "0\(String(remainingMilliseconds))"}
        return String(remainingMilliseconds)
    }()
    return "\(minuteString):\(secondString).\(msString)"
}

struct LocalRanking {
    let livesRemaining: Int
    let lengthInMs: Int

    func formattedLength() -> String {
        return format(milliseconds: lengthInMs)
    }
}

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

    func formattedLength() -> String {
        return format(milliseconds: lengthInMs)
    }
}

struct NamedRanking {
    let livesRemaining: Int
    let lengthInMs: Int
    let rank: Int
    let startedAt: Date
    let name: String
    let anonymous: Bool

    static func from(dict: [String: Any]) -> NamedRanking? {
        guard let livesRemaining = dict["livesRemaining"] as? Int else { return nil }
        guard let lengthInMs = dict["lengthInMs"] as? Int else { return nil }
        guard let rank = dict["rank"] as? Int else { return nil }
        guard let dateString = dict["startedAt"] as? String else { return nil }
        guard let name = dict["name"] as? String else { return nil }
        guard let anonymous = dict["anonymous"] as? Bool else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let startedAt = dateFormatter.date(from: dateString) else { return nil }

        return NamedRanking(
            livesRemaining: livesRemaining,
            lengthInMs: lengthInMs,
            rank: rank,
            startedAt: startedAt,
            name: name,
            anonymous: anonymous
        )
    }
}
