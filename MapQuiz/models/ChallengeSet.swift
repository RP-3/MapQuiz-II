//
//  Continent.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import UIKit

enum ChallengeSet: String, CaseIterable {
    // continents
    case northAmerica = "NA"
    case southAmerica = "SA"
    case asia = "AS"
    case europe = "EU"
    case oceania = "OC"
    case africa = "AF"

    // US states
    case usStates = "US_STATES"

    func str() -> String { return self.rawValue }

    func title() -> String {
        switch self {
        case .northAmerica: return "North America"
        case .southAmerica: return "South America"
        case .asia: return "Asia"
        case .europe: return "Europe"
        case .oceania: return "Oceania"
        case .africa: return "Africa"
        case .usStates: return "US States"
        }
    }

    static func from(str: String?) -> ChallengeSet? {
        guard let str = str else { return nil }
        switch str {
        case "NA": return .northAmerica
        case "SA": return .southAmerica
        case "AS": return .asia
        case "EU": return .europe
        case "OC": return .oceania
        case "AF": return .africa
        case "US_STATES": return .usStates
        default: return nil
        }
    }

    func toPickerImage() -> UIImage {
        switch self {
        case .northAmerica: return UIImage(named: "pickNorthAmerica")!
        case .southAmerica: return UIImage(named: "pickSouthAmerica")!
        case .asia: return UIImage(named: "pickAsia")!
        case .europe: return UIImage(named: "pickEurope")!
        case .oceania: return UIImage(named: "pickOceania")!
        case .africa: return UIImage(named: "pickAfrica")!
        case .usStates: return UIImage(named: "pickUsStates")!
        }
    }

    func toTableCellImage() -> UIImage {
        switch self {
        case .northAmerica: return UIImage(named: "northAmerica")!
        case .southAmerica: return UIImage(named: "southAmerica")!
        case .asia: return UIImage(named: "asia")!
        case .europe: return UIImage(named: "europe")!
        case .oceania: return UIImage(named: "oceania")!
        case .africa: return UIImage(named: "africa")!
        case .usStates: return UIImage(named: "usStates")!
        }
    }

    static func at(index: Int) -> ChallengeSet {
        switch index {
        case 0: return .northAmerica
        case 1: return .southAmerica
        case 2: return .asia
        case 3: return .europe
        case 4: return .oceania
        default: return .africa
        }
    }
}
