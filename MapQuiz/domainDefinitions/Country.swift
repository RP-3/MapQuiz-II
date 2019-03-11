//
//  LandArea.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import Foundation
import MapKit

enum GeoJsonFormat {
    case polygon
    case multipolygon
}

struct Country {
    let name: String
    let boundary: [[CLLocationCoordinate2D]]
    let boundaryPointsCount: NSInteger
    let geojsonFormat: GeoJsonFormat
    let annotation_point: CLLocationCoordinate2D
}
