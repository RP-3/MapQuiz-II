//
//  World.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import MapKit

class World {

    private static let smallIslandNames: Set<String> = [
        "Marshall Islands",
        "Kiribati",
        "Maldives",
        "Tonga",
        "Micronesia",
        "Niue",
        "Nauru",
        "Tuvalu",
        "Samoa",
        "Cook Islands",
        "Palau",
        "Mauritius",
        "Comoros",
        "Seychelles",
    ]

    public static func regionFor(continent: Continent) -> MKCoordinateRegion {
        let coords: CLLocationCoordinate2D = {
            switch continent {
            case .northAmerica: return CLLocationCoordinate2D(latitude: 50, longitude: -101)
            case .southAmerica: return CLLocationCoordinate2D(latitude: -19, longitude: -60)
            case .europe: return CLLocationCoordinate2D(latitude: 60, longitude: 10)
            case .africa: return CLLocationCoordinate2D(latitude: 10, longitude: 22)
            case .asia: return CLLocationCoordinate2D(latitude: 35, longitude: 85)
            case .oceania: return CLLocationCoordinate2D(latitude: -14, longitude: 160)
            }
        }()

        let span = MKCoordinateSpan(latitudeDelta: 100.0, longitudeDelta: 100.0)
        return MKCoordinateRegion(center: coords, span: span)
    }

    public static func timeLimitFor(continent: Continent) -> Double {
        switch continent {
        case .northAmerica: return (3*60) + 12
        case .southAmerica: return (1*60) + 36
        case .europe: return (6*60) + 0
        case .africa: return (7*60) + 20
        case .asia: return (5*60) + 52
        case .oceania: return (2*60) + 16
        }
    }

    public static func coordinates(_ coords: CLLocationCoordinate2D, inCountry country: Country) -> Bool {
        if World.smallIslandNames.contains(country.name) {
            // perform match based on proximity
            let givenLocation = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
            let atnPoint = country.annotation_point
            let approxIslandLocation = CLLocation(latitude: atnPoint.latitude, longitude: atnPoint.longitude)
            return givenLocation.distance(from: approxIslandLocation)/1000 < 500 // less than 500km
        } else {
            // perform match based on containment
            for polygon in country.boundary {
                var unsafePointerToPolygon = polygon
                let polygonRenderer = MKPolygonRenderer(polygon: MKPolygon(coordinates: &unsafePointerToPolygon, count: polygon.count))
                let guessCoords: CGPoint = polygonRenderer.point(for: MKMapPoint(coords))
                if polygonRenderer.path.contains(guessCoords) { return true }
            }
            return false
        }
    }

    public static func shuffle(countries: [Country]) -> [Country] {
        var result = countries.map { $0 }
        for i in 0 ... (countries.count - 1) {
            let randomIndex = Int.random(in: 0 ..< result.count)
            let tmp = result[i]
            result[i] = result[randomIndex]
            result[randomIndex] = tmp
        }
        return result
    }
}
