//
//  LandArea.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import GLKit
import MapKit

enum GeoJsonFormat {
    case polygon
    case multipolygon
}

struct BoundedItem {
    let name: String
    let boundary: [[CLLocationCoordinate2D]]
    let boundaryPointsCount: NSInteger
    let geojsonFormat: GeoJsonFormat

    func centroid() -> CLLocationCoordinate2D {
        // find the biggest polygon by area
        var biggestPolygonIndex = 0
        var biggestPolygonArea = 0
        for i in 0..<boundary.count {
            let polygon = boundary[i]
            let area = Int(regionArea(locations: polygon))
            if area > biggestPolygonArea {
                biggestPolygonIndex = i
                biggestPolygonArea = area
            }
        }
        let biggestPolygon = boundary[biggestPolygonIndex]
        var centroidByMass = centreOfMass(biggestPolygon)

        // set up a renderer for quick geometric calcs
        let renderer = MKPolygonRenderer(polygon: MKPolygon(coordinates: biggestPolygon, count: biggestPolygon.count))
        func contains(pt: CLLocationCoordinate2D) -> Bool {
            return renderer.path.contains(renderer.point(for: MKMapPoint(pt)))
        }

        // centre of mass is inside shape, so just use that
        if contains(pt: centroidByMass) { return centroidByMass }

        // find the left-most point inside the bounding box at this latitude that's inside the shape
        var minLon: CLLocationDegrees = 180
        var maxLon: CLLocationDegrees = -180
        for pt in biggestPolygon {
            minLon = min(minLon, pt.longitude)
            maxLon = max(maxLon, pt.longitude)
        }

        centroidByMass.longitude = minLon
        while !contains(pt: centroidByMass) && centroidByMass.longitude < maxLon {
            centroidByMass.longitude += 0.1 // approx 10km at equator
        }
        return centroidByMass
    }
}

fileprivate func centreOfMass(_ LocationPoints: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
    var x:Float = 0.0;
    var y:Float = 0.0;
    var z:Float = 0.0;
    for points in LocationPoints {
    let lat = GLKMathDegreesToRadians(Float(points.latitude));
        let long = GLKMathDegreesToRadians(Float(points.longitude));
        x += cos(lat) * cos(long);
        y += cos(lat) * sin(long);
        z += sin(lat);
    }
    x = x / Float(LocationPoints.count);
    y = y / Float(LocationPoints.count);
    z = z / Float(LocationPoints.count);
    let resultLong = atan2(y, x);
    let resultHyp = sqrt(x * x + y * y);
    let resultLat = atan2(z, resultHyp);
    let result = CLLocationCoordinate2D(
        latitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLat))),
        longitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLong)))
    );
    return result;
}

fileprivate func radians(degrees: Double) -> Double {
    return degrees * .pi / 180
}

fileprivate func regionArea(locations: [CLLocationCoordinate2D]) -> Double {
    let kEarthRadius = 6378137.0
    guard locations.count > 2 else { return 0 }
    var area = 0.0

    for i in 0..<locations.count {
        let p1 = locations[i > 0 ? i - 1 : locations.count - 1]
        let p2 = locations[i]

        area += radians(degrees: p2.longitude - p1.longitude) * (2 + sin(radians(degrees: p1.latitude)) + sin(radians(degrees: p2.latitude)) )
    }
    area = -(area * kEarthRadius * kEarthRadius / 2)
    return max(area, -area)
}
