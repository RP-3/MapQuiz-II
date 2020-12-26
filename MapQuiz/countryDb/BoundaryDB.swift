//
//  BoundaryDB.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import Foundation
import MapKit

fileprivate typealias JSONObject = Dictionary<String, AnyObject>

class BoundaryDB {

    static private var challengeSetSizes: [ChallengeSet : Int] = [:]

    public static func size(of challengeSet: ChallengeSet) -> Int {
        if let size = challengeSetSizes[challengeSet] { return size }
        challengeSetSizes[challengeSet] = boundedItems(inChallengeSet: challengeSet).count
        return challengeSetSizes[challengeSet]!
    }

    public static func boundedItems(inChallengeSet challengeSet: ChallengeSet) -> [BoundedItem] {
        var result: [BoundedItem] = Array()

        for fileName in challengeSet.dataFiles {
            let path = Bundle.main.path(forResource: "data/\(fileName)", ofType: "json")!
            let url = URL(fileURLWithPath: path)
            let data = try! Data(contentsOf: url, options: .mappedIfSafe)
            let jsonResult = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [JSONObject]

            let parsedItemsInFile = jsonResult.compactMap { (obj: JSONObject) -> BoundedItem? in
                let boundaryType: GeoJsonFormat = {
                    switch obj["type"] as! String {
                    case "Polygon": return .polygon
                    case "MultiPolygon": return .multipolygon
                    default:
                        fatalError("Warning: Unknown boundary type \(obj["type"] as! String)")
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

                let annotPtStr = (obj["centroid"] as! String).components(separatedBy: ",")
                let annotationPoint = CLLocationCoordinate2D(latitude: Double(annotPtStr[0])!, longitude: Double(annotPtStr[1])!)

                return BoundedItem(
                    name: obj["name"]! as! String,
                    boundary: boundary,
                    boundaryPointsCount: boundaryPointsCount,
                    geojsonFormat: boundaryType,
                    annotation_point: annotationPoint
                )
            }

            result.append(contentsOf: parsedItemsInFile)
        }

        return result
    }
}
