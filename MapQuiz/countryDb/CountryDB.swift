//
//  CountryDB.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import Foundation
import MapKit

fileprivate typealias JSONObject = Dictionary<String, AnyObject>

class CountryDB {

    public static func countries(inContinent continent: Continent) -> [Country] {

        let path = Bundle.main.path(forResource: "countryData", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let jsonResult = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [JSONObject]

        return jsonResult
            .filter { $0["continent"] as! String == continent.rawValue }
            .map { (obj: JSONObject) -> Country in

            let boundaryType: GeoJsonFormat = {
                switch obj["coordinates_type"] as! String {
                case "Polygon": return .polygon
                case "MultiPolygon": return .multipolygon
                default:
                    print("Warning: Unknown boundary type \(obj["coordinates_type"] as! String)")
                    return .polygon
                }
            }()

            var boundaryPointsCount = 0
            let boundary: [[CLLocationCoordinate2D]] = {
                switch boundaryType {
                case .polygon:
                    let points = (obj["coordinates"] as! [[[CLLocationDegrees]]]).first!
                    boundaryPointsCount = points.count
                    return [points.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }]
                case .multipolygon:
                    let polygons = (obj["coordinates"] as! [[[[CLLocationDegrees]]]])
                    return polygons.map { (polygon: [[[CLLocationDegrees]]]) -> [CLLocationCoordinate2D] in
                        return polygon[0].map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }
                    }
                }
            }()

            let annotPtStr = (obj["lat_long"] as! String).components(separatedBy: ",")
            let annotationPoint = CLLocationCoordinate2D(latitude: Double(annotPtStr[0])!, longitude: Double(annotPtStr[1])!)

            return Country(
                name: obj["country"]! as! String,
                boundary: boundary,
                boundaryPointsCount: boundaryPointsCount,
                geojsonFormat: boundaryType,
                annotation_point: annotationPoint
            )
        }
    }

}
