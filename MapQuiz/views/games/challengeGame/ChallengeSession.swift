//
//  ChallengeSession.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import MapKit

struct ChallengeSessionGameState {
    let itemCount: Int
    let itemsHandled: Int
    let livesRemaining: Int
    let currentItemName: String?
}

class ChallengeSession {

    private let totalItems: Int
    public let challengeSet: ChallengeSet
    public var startTime: Date?
    public var endTime: Date?

    private var itemsHandled: [BoundedItem]
    private var itemsRemaining: [BoundedItem]
    private var livesRemaining: Int
    private var finished = false
    public var attempts: [ChallengeSessionAttempt]

    init(challengeSet: ChallengeSet){
        let itemList = BoundaryDB.boundedItems(inChallengeSet: challengeSet)
        self.challengeSet = challengeSet
        totalItems = itemList.count
        itemsHandled = []
        attempts = []
        itemsRemaining = World.shuffle(countries: itemList)
        livesRemaining = 3
    }

    public func currentGameState() -> ChallengeSessionGameState {
        return ChallengeSessionGameState(
            itemCount: totalItems,
            itemsHandled: itemsHandled.count,
            livesRemaining: livesRemaining,
            currentItemName: itemsRemaining.last?.name
        )
    }

    public func dangerousElapsedTimeInMs() -> TimeInterval{
        return endTime!.timeIntervalSince(startTime!) * 1000
    }

    public func remainingCountries() -> [BoundedItem] { return self.itemsRemaining }

    public func gameOver() -> Bool { return itemsRemaining.count == 0 || livesRemaining == 0 || finished }

    public func guess(coords: CLLocationCoordinate2D) -> (BoundedItem?, GuessOutcome) {
        guard let currentItem = itemsRemaining.last else { return (nil, .fatFingered) }
        // guessed correctly
        let now = NSDate().timeIntervalSince1970
        if World.coordinates(coords, inItem: currentItem) {
            itemsHandled.append(itemsRemaining.popLast()!)
            if itemsRemaining.count == 0 { finish() }
            attempts.append(ChallengeSessionAttempt(itemToFind: currentItem, itemGuessed: currentItem, attemptedAt: now))
            return (currentItem, .correct)
        }
        // guessed incorrectly
        for item in itemsRemaining {
            if World.coordinates(coords, inItem: item) {
                livesRemaining -= 1
                if livesRemaining == 0 { finish() }
                attempts.append(ChallengeSessionAttempt(itemToFind: currentItem, itemGuessed: item, attemptedAt: now))
                return (nil, .wrong)
            }
        }
        return (nil, .fatFingered) // fat fingered
    }

    public func start(){ startTime = startTime ?? Date.init() }

    public func skip(){
        itemsRemaining.insert(itemsRemaining.popLast()!, at: 0)
    }

    public func finish() {
        finished = true
        endTime = endTime ?? Date.init()
        ChallengeSessionRegistry.shared.enqueue(session: self)
        RankCache.shared.saveSummary(for: self)
    }

    public func completed() -> Bool {
        return self.livesRemaining > 0 && self.itemsRemaining.count == 0
    }

    public func summary() -> ChallengeSessionSummary {
        let duration = Int(dangerousElapsedTimeInMs())
        return ChallengeSessionSummary(livesRemaining: self.livesRemaining, lengthInMs: duration)
    }
}

struct ChallengeSessionSummary {
    let livesRemaining: Int
    let lengthInMs: Int
}

