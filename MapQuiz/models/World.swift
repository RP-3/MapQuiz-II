//
//  World.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import MapKit

class World {

    private static let smallIslandNames: [String:CLLocationDistance] = [
        // oceania
        "Marshall Islands": 500_000,
        "Kiribati": 500_000,
        "Tonga": 400_000,
        "Micronesia": 500_000,
        "Niue": 300_000,
        "Nauru": 500_000,
        "Tuvalu": 500_000,
        "Samoa": 400_000,
        "Cook Islands": 500_000,
        "Palau": 500_000,
        "Vanuatu": 100_000,

        // europe
        "Malta": 50_000,
        "Vatican City": 50_000,
        "San Marino": 50_000,

        // africa
        "Mauritius": 500_000,
        "Comoros": 500_000,
        "Seychelles": 500_000,
        "São Tomé and Príncipe": 500_000,

        // asia
        "Maldives": 200_000,
        "Singapore": 200_000,
        "Bahrain": 30_000,

        // north america
        "Barbados": 100_000,
        "Dominica": 100_000,
        "Saint Kitts and Nevis": 50_000,
        "Saint Vincent and the Grenadines": 50_000,
        "Antigua and Barbuda": 60_000,
        "Grenada": 90_000,
        "Saint Lucia": 80_000,
    ]

    public static func regionFor(challengeSet: ChallengeSet) -> MKCoordinateRegion {
        let coords: CLLocationCoordinate2D = {
            switch challengeSet {
            case .northAmerica: return CLLocationCoordinate2D(latitude: 50, longitude: -101)
            case .southAmerica: return CLLocationCoordinate2D(latitude: -19, longitude: -60)
            case .europe: return CLLocationCoordinate2D(latitude: 60, longitude: 10)
            case .africa: return CLLocationCoordinate2D(latitude: 10, longitude: 22)
            case .asia: return CLLocationCoordinate2D(latitude: 35, longitude: 85)
            case .oceania: return CLLocationCoordinate2D(latitude: -14, longitude: 160)
            case .world: return CLLocationCoordinate2D(latitude: 0, longitude: 0)
            case .usStates: return CLLocationCoordinate2D(latitude: 39, longitude: -106)
            }
        }()

        let span = MKCoordinateSpan(latitudeDelta: 100.0, longitudeDelta: 100.0)
        return MKCoordinateRegion(center: coords, span: span)
    }

    public static func timeLimitFor(challengeSet: ChallengeSet) -> Double {
        switch challengeSet { // ~8 seconds per item. Written as (m*60) mins + s seconds
        case .northAmerica: return (3*60) + 12
        case .southAmerica: return (1*60) + 36
        case .europe: return (6*60) + 0
        case .africa: return (7*60) + 20
        case .asia: return (5*60) + 52
        case .oceania: return (2*60) + 16
        case .world: return (10*60) + 0 // TODO: figure out how much time actually give them
        case .usStates: return (6*60) + 40
        }
    }

    public static func smallIsland(name: String) -> CLLocationDistance? {
        return World.smallIslandNames[name]
    }

    public static func coordinates(_ coords: CLLocationCoordinate2D, inItem item: BoundedItem) -> Bool {
        if let radius = smallIsland(name: item.name) {
            // perform match based on proximity
            let givenLocation = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
            let atnPoint = item.annotation_point
            let approxIslandLocation = CLLocation(latitude: atnPoint.latitude, longitude: atnPoint.longitude)
            return givenLocation.distance(from: approxIslandLocation) < radius
        } else {
            // perform match based on containment
            for polygon in item.boundary {
                var unsafePointerToPolygon = polygon
                let polygonRenderer = MKPolygonRenderer(polygon: MKPolygon(coordinates: &unsafePointerToPolygon, count: polygon.count))
                let guessCoords: CGPoint = polygonRenderer.point(for: MKMapPoint(coords))
                if polygonRenderer.path.contains(guessCoords) { return true }
            }
            return false
        }
    }

    public static func shuffle(countries: [BoundedItem]) -> [BoundedItem] {
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
