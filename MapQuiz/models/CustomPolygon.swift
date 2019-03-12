//
//  CustomPolygon.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import MapKit

class CustomPolygon: MKPolygon {

    var userGuessed: Bool!
    var annotation_point: CLLocationCoordinate2D!

    convenience init(
        guessed: Bool,
        lat_long: CLLocationCoordinate2D,
        coords: [CLLocationCoordinate2D],
        numberOfPoints: Int)
    {
        var coords = coords
        self.init(coordinates: &coords, count: numberOfPoints)
        userGuessed = guessed
        annotation_point = lat_long
    }
}
