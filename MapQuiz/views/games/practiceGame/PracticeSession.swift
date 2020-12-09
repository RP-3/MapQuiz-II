//
//  PracticeSession.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import MapKit

struct PracticeGameState {
    let itemCount: Int
    let itemsHandled: Int
    let revealed: Int
    let misses: Int
    let currentItemName: String?
}

class PracticeSession {

    private let totalItems: Int
    public let challengeSet: ChallengeSet
    private var revealed: Int
    private var misses: Int

    private var itemsHandled: [BoundedItem]
    private var itemsRemaining: [BoundedItem]

    init(challengeSet: ChallengeSet) {
        let itemList = BoundaryDB.boundedItems(inChallengeSet: challengeSet)
        self.challengeSet = challengeSet
        totalItems = itemList.count
        revealed = 0
        misses = 0
        itemsHandled = []
        itemsRemaining = World.shuffle(countries: itemList)
    }

    public func currentGameState() -> PracticeGameState {
        return PracticeGameState(
            itemCount: totalItems,
            itemsHandled: itemsHandled.count,
            revealed: revealed,
            misses: misses,
            currentItemName: itemsRemaining.last?.name
        )
    }

    public func remainingCountries() -> [BoundedItem] { return self.itemsRemaining }

    public func finished() -> Bool { return itemsRemaining.count == 0 }

    public func guess(coords: CLLocationCoordinate2D) -> (BoundedItem?, GuessOutcome) {
        guard let currentItem = itemsRemaining.last else { return (nil, .fatFingered) }
        // guessed correctly
        if World.coordinates(coords, inItem: currentItem) {
            itemsHandled.append(itemsRemaining.popLast()!)
            return (currentItem, .correct)
        }
        // guessed incorrectly
        for item in itemsRemaining {
            if World.coordinates(coords, inItem: item) {
                misses += 1
                return (nil, .wrong)
            }
        }
        return (nil, .fatFingered) // fat fingered
    }

    public func skip(){
        guard let itemToRemove = itemsRemaining.popLast() else { return }
        itemsRemaining.insert(itemToRemove, at: 0)
    }

    public func reveal(){
        guard let itemToReveal = itemsRemaining.popLast() else { return }
        itemsHandled.append(itemToReveal)
        revealed += 1
    }

}
