//
//  ChallegeSet.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import UIKit
import MapKit

class ChallengeSet: Hashable {
    let slug: String
    let title: String
    let pickerImage: UIImage
    let tableCellImage: UIImage
    let collectionDescriptor: String
    let region: MKCoordinateRegion
    let timeLimit: Double

    init(_ slug: String, _ title: String, _ pickerImage: UIImage, _ tableCellImage: UIImage, _ collectionDescriptor: String, _ region: MKCoordinateRegion, _ timeLimit: Double){
        self.slug = slug
        self.title = title
        self.pickerImage = pickerImage
        self.tableCellImage = tableCellImage
        self.collectionDescriptor = collectionDescriptor
        self.region = region
        self.timeLimit = timeLimit
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(slug)
    }

    static func == (lhs: ChallengeSet, rhs: ChallengeSet) -> Bool {
        return lhs.slug == rhs.slug
    }
}

class ChallengeSetCollection {
    let header: String
    let challengeSets: [ChallengeSet]

    init(header: String, challengeSets: [ChallengeSet]) {
        self.header = header
        self.challengeSets = challengeSets
    }
}

class ChallengeSets {
    //                           slug     title            picker                   tableCellImage              collectionDescriptor                     region                 timeLimit
    static let NA = ChallengeSet("NA",    "North America", img("pickNorthAmerica"), img("northAmerica"),        "countries & islands",                   region(50, -101, 100), 24*6)
    static let SA = ChallengeSet("SA",    "South America", img("pickSouthAmerica"), img("southAmerica"),        "countries",                             region(-19, -60, 100), 13*6)
    static let AS = ChallengeSet("AS",    "Asia",          img("pickAsia"),         img("asia"),                "countries",                             region(35, 85, 100),   47*6)
    static let EU = ChallengeSet("EU",    "Europe",        img("pickEurope"),       img("europe"),              "countries and city states",             region(60, 10, 100),   46*6)
    static let OC = ChallengeSet("OC",    "Oceania",       img("pickOceania"),      img("oceania"),             "countries",                             region(-14, 160, 100), 17*6)
    static let AF = ChallengeSet("AF",    "Africa",        img("pickAfrica"),       img("africa"),              "countries",                             region(10, 22, 100),   54*6)
    static let WORLD = ChallengeSet("WORLD", "World",         img("pickWorld"),        img("worldIcon"),        "countries, islands and city states",    region(0, 0, 100),     200*6)
    static let US_STATES = ChallengeSet("US_STATES", "US States & Territories",  img("pickUsStates"), img("usStates"), "states & territories",           region(39, -106, 100), 50*6)
    static let GB_COUNTIES = ChallengeSet("GB_COUNTIES", "British Counties (Ceremonial)",  img("pickUsStates"), img("usStates"), "ceremonial counties", region(60, 10, 40),     91*6)

    static let all = [
        ChallengeSetCollection(header: "Countries of the World", challengeSets: [NA, SA, AS, EU, OC, AF, WORLD]),
        ChallengeSetCollection(header: "United Kingdom", challengeSets: [GB_COUNTIES]),
        ChallengeSetCollection(header: "United States", challengeSets: [US_STATES]),
    ]

    static let flattened = [NA, SA, AS, EU, OC, AF, WORLD, US_STATES, GB_COUNTIES]

    static func from(slug: String) -> ChallengeSet? {
        for collection in self.all {
            for cs in collection.challengeSets {
                if cs.slug == slug {
                    return cs
                }
            }
        }
        return nil
    }
}

// syntactic helpers
fileprivate func img(_ name: String) -> UIImage {
    return UIImage(named: name)!
}

fileprivate func coords(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
}

fileprivate func span(_ delta: CLLocationDegrees) -> MKCoordinateSpan {
    return MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
}

fileprivate func region(_ lat: CLLocationDegrees, _ lon: CLLocationDegrees, _ delta: CLLocationDegrees) -> MKCoordinateRegion {
    let c = coords(lat, lon)
    let s = span(delta)
    return MKCoordinateRegion(center: c, span: s)
}
