//
//  ChallengeSession.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import MapKit

struct ChallengeSessionGameState {
    let countryCount: Int
    let countriesHandled: Int
    let livesRemaining: Int
    let currentCountryName: String?
}

class ChallengeSession {

    private let totalCountries: Int
    public var startTime: Date?

    private var countriesHandled: [Country]
    private var countriesRemaining: [Country]
    private var livesRemaining: Int
    private var timedOut = false

    init(continent: Continent){
        let countryList = CountryDB.countries(inContinent: continent)
        totalCountries = countryList.count
        countriesHandled = []
        countriesRemaining = World.shuffle(countries: countryList)
        livesRemaining = 3
    }

    public func currentGameState() -> ChallengeSessionGameState {
        return ChallengeSessionGameState(
            countryCount: totalCountries,
            countriesHandled: countriesHandled.count,
            livesRemaining: livesRemaining,
            currentCountryName: countriesRemaining.last?.name
        )
    }

    public func remainingCountries() -> [Country] { return self.countriesRemaining }

    public func finished() -> Bool { return countriesRemaining.count == 0 || livesRemaining == 0 || timedOut }

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
                livesRemaining -= 1
                return (nil, .wrong)
            }
        }
        return (nil, .fatFingered) // fat fingered
    }

    public func start(){ startTime = startTime ?? Date.init() }

    public func timeout() { timedOut = true }
}
