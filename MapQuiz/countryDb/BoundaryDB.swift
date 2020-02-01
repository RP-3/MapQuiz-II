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

class BoundaryDB {

    public static func boundedItems(inChallengeSet challengeSet: ChallengeSet) -> [BoundedItem] {

        let config = mapping(forChallengeSet: challengeSet)

        let data = try! Data(contentsOf: config.dataFileURL, options: .mappedIfSafe)
        let jsonResult = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [JSONObject]

        return jsonResult
            .compactMap { (obj: JSONObject) -> BoundedItem? in

            if challengeSet != .usStates { // challenge is a continent
                let continent = obj["continent"] as! String
                guard continent == challengeSet.str() else { return nil }
            }

            let boundaryType: GeoJsonFormat = {
                switch obj[config.typeKey] as! String {
                case "Polygon": return .polygon
                case "MultiPolygon": return .multipolygon
                default:
                    print("Warning: Unknown boundary type \(obj[config.typeKey] as! String)")
                    return .polygon
                }
            }()

            var boundaryPointsCount = 0
            let boundary: [[CLLocationCoordinate2D]] = {
                switch boundaryType {
                case .polygon:
                    let points = (obj[config.coordsKey] as! [[[CLLocationDegrees]]]).first!
                    boundaryPointsCount = points.count
                    return [points.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }]
                case .multipolygon:
                    let polygons = (obj[config.coordsKey] as! [[[[CLLocationDegrees]]]])
                    return polygons.map { (polygon: [[[CLLocationDegrees]]]) -> [CLLocationCoordinate2D] in
                        return polygon[0].map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }
                    }
                }
            }()

            let annotPtStr = (obj[config.annotationPointKey] as! String).components(separatedBy: ",")
            let annotationPoint = CLLocationCoordinate2D(latitude: Double(annotPtStr[0])!, longitude: Double(annotPtStr[1])!)

            return BoundedItem(
                name: obj[config.nameKey]! as! String,
                boundary: boundary,
                boundaryPointsCount: boundaryPointsCount,
                geojsonFormat: boundaryType,
                annotation_point: annotationPoint
            )
        }
    }

    private static func mapping(forChallengeSet challengeSet: ChallengeSet) -> GeoJsonMapping {
        if challengeSet == .usStates {
            let stateDataPath = Bundle.main.path(forResource: "USStateData", ofType: "json")!
            return GeoJsonMapping(
                dataFileURL: URL(fileURLWithPath: stateDataPath),
                typeKey: "type",
                coordsKey: "coordinates",
                nameKey: "name",
                annotationPointKey: "annotationCoords"
            )
        } else {
            let countryDataPath = Bundle.main.path(forResource: "countryData", ofType: "json")!
            return GeoJsonMapping(
                dataFileURL: URL(fileURLWithPath: countryDataPath),
                typeKey: "coordinates_type",
                coordsKey: "coordinates",
                nameKey: "country",
                annotationPointKey: "lat_long"
            )
        }
    }
}

fileprivate struct GeoJsonMapping {
    let dataFileURL: URL
    let typeKey: String
    let coordsKey: String
    let nameKey: String
    let annotationPointKey: String
}
