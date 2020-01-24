//
//  Continent.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import UIKit

enum Continent: String {
    case northAmerica = "NA"
    case southAmerica = "SA"
    case asia = "AS"
    case europe = "EU"
    case oceania = "OC"
    case africa = "AF"

    func str() -> String { return self.rawValue }

    static func from(str: String?) -> Continent? {
        guard let str = str else { return nil }
        switch str {
        case "NA": return .northAmerica
        case "SA": return .southAmerica
        case "AS": return .asia
        case "EU": return .europe
        case "OC": return .oceania
        case "AF": return .africa
        default: return nil
        }
    }

    func toString() -> String {
        switch self {
        case .northAmerica: return "North\nAmerica"
        case .southAmerica: return "S.A."
        case .asia: return "ASIA"
        case .europe: return "EU"
        case .oceania: return "OC"
        case .africa: return "AF"
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
        }
    }
}
