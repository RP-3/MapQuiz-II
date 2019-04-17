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

    private let totalCountries: Int
    private var revealed: Int
    private var misses: Int

    private var countriesHandled: [Country]
    private var countriesRemaining: [Country]

    init(continent: Continent) {
        let countryList = CountryDB.countries(inContinent: continent)
        totalCountries = countryList.count
        revealed = 0
        misses = 0
        countriesHandled = []
        countriesRemaining = World.shuffle(countries: countryList)
    }

    public func currentGameState() -> PracticeGameState {
        return PracticeGameState(
            countryCount: totalCountries,
            countriesHandled: countriesHandled.count,
            revealed: revealed,
            misses: misses,
            currentCountryName: countriesRemaining.last?.name
        )
    }

    public func remainingCountries() -> [Country] { return self.countriesRemaining }

    public func finished() -> Bool { return countriesRemaining.count == 0 }

    public func guess(coords: CLLocationCoordinate2D) -> (Country?, GuessOutcome) {
        guard let currentCountry = countriesRemaining.last else { return (nil, .fatFingered) }
        // guessed correctly
        if World.coordinates(coords, inCountry: currentCountry) {
            countriesHandled.append(countriesRemaining.popLast()!)
            return (currentCountry, .correct)
        }
        // guessed incorrectly
        for country in countriesRemaining {
            if World.coordinates(coords, inCountry: country) {
                misses += 1
                return (nil, .wrong)
            }
        }
        return (nil, .fatFingered) // fat fingered
    }

    public func skip(){
        guard let countryToRemove = countriesRemaining.popLast() else { return }
        countriesRemaining.insert(countryToRemove, at: 0)
    }

    public func reveal(){
        guard let countryToReveal = countriesRemaining.popLast() else { return }
        countriesHandled.append(countryToReveal)
        revealed += 1
    }

}
