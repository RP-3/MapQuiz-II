//
//  PracticeSession.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import MapKit

struct PracticeGameState {
    let countryCount: Int
    let countriesHandled: Int
    let revealed: Int
    let misses: Int
    let currentCountryName: String?
}

class PracticeSession {

    private let totalItems: Int
    private var revealed: Int
    private var misses: Int

    private var itemsHandled: [BoundedItem]
    private var itemsRemaining: [BoundedItem]

    init(challengeSet: ChallengeSet) {
        let countryList = BoundaryDB.boundedItems(inChallengeSet: challengeSet)
        totalItems = countryList.count
        revealed = 0
        misses = 0
        itemsHandled = []
        itemsRemaining = World.shuffle(countries: countryList)
    }

    public func currentGameState() -> PracticeGameState {
        return PracticeGameState(
            countryCount: totalItems,
            countriesHandled: itemsHandled.count,
            revealed: revealed,
            misses: misses,
            currentCountryName: itemsRemaining.last?.name
        )
    }

    public func remainingCountries() -> [BoundedItem] { return self.itemsRemaining }

    public func finished() -> Bool { return itemsRemaining.count == 0 }

    public func guess(coords: CLLocationCoordinate2D) -> (BoundedItem?, GuessOutcome) {
        guard let currentCountry = itemsRemaining.last else { return (nil, .fatFingered) }
        // guessed correctly
        if World.coordinates(coords, inCountry: currentCountry) {
            itemsHandled.append(itemsRemaining.popLast()!)
            return (currentCountry, .correct)
        }
        // guessed incorrectly
        for country in itemsRemaining {
            if World.coordinates(coords, inCountry: country) {
                misses += 1
                return (nil, .wrong)
            }
        }
        return (nil, .fatFingered) // fat fingered
    }

    public func skip(){
        guard let countryToRemove = itemsRemaining.popLast() else { return }
        itemsRemaining.insert(countryToRemove, at: 0)
    }

    public func reveal(){
        guard let countryToReveal = itemsRemaining.popLast() else { return }
        itemsHandled.append(countryToReveal)
        revealed += 1
    }

}
