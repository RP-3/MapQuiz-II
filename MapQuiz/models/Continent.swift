//
//  Continent.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

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
}
