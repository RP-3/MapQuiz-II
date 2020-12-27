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
        var resultSet: [CLLocationCoordinate2D] = Array()
        for polygon in boundary {
            resultSet.append(centreOfPolygon(polygon))
        }
        return centreOfPolygon(resultSet)
    }

    private func centreOfPolygon(_ LocationPoints: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D{
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
       let result = CLLocationCoordinate2D(latitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLat))), longitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLong))));
       return result;
   }
}
