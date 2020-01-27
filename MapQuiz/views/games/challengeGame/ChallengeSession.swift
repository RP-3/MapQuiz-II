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
    public let continent: ChallengeSet
    public var startTime: Date?
    public var endTime: Date?

    private var countriesHandled: [BoundedItem]
    private var countriesRemaining: [BoundedItem]
    private var livesRemaining: Int
    private var finished = false
    public var attempts: [ChallengeSessionAttempt]

    init(continent: ChallengeSet){
        let countryList = BoundaryDB.boundedItems(inChallengeSet: continent)
        self.continent = continent
        totalCountries = countryList.count
        countriesHandled = []
        attempts = []
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

    public func dangerousElapsedTimeInMs() -> TimeInterval{
        return endTime!.timeIntervalSince(startTime!) * 1000
    }

    public func remainingCountries() -> [BoundedItem] { return self.countriesRemaining }

    public func gameOver() -> Bool { return countriesRemaining.count == 0 || livesRemaining == 0 || finished }

    public func guess(coords: CLLocationCoordinate2D) -> (BoundedItem?, GuessOutcome) {
        guard let currentCountry = countriesRemaining.last else { return (nil, .fatFingered) }
        // guessed correctly
        let now = NSDate().timeIntervalSince1970
        if World.coordinates(coords, inCountry: currentCountry) {
            countriesHandled.append(countriesRemaining.popLast()!)
            if countriesRemaining.count == 0 { finish() }
            attempts.append(ChallengeSessionAttempt(countryToFind: currentCountry, countryGuessed: currentCountry, attemptedAt: now))
            return (currentCountry, .correct)
        }
        // guessed incorrectly
        for country in countriesRemaining {
            if World.coordinates(coords, inCountry: country) {
                livesRemaining -= 1
                if livesRemaining == 0 { finish() }
                attempts.append(ChallengeSessionAttempt(countryToFind: currentCountry, countryGuessed: country, attemptedAt: now))
                return (nil, .wrong)
            }
        }
        return (nil, .fatFingered) // fat fingered
    }

    public func start(){ startTime = startTime ?? Date.init() }

    public func skip(){
        countriesRemaining.insert(countriesRemaining.popLast()!, at: 0)
    }

    public func finish() {
        finished = true
        endTime = endTime ?? Date.init()
        ChallengeSessionRegistry.shared.enqueue(session: self)
    }
}
