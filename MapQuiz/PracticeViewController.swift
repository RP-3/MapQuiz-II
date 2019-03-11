//
//  PracticeViewController.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import UIKit
import MapKit

class PracticeViewController: UIViewController {

    public var continent: Continent!
    private let mapDelegate = MapViewDelegate()
    @IBOutlet weak var worldMap: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        worldMap.delegate = mapDelegate
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CountryDB.countries(inContinent: continent).forEach { (country: Country) -> Void in
            for landArea in (country.boundary) {
                let overlay = CustomPolygon(guessed: false, lat_long: country.annotation_point, coords: landArea, numberOfPoints: landArea.count )
                overlay.title = country.name
                worldMap.addOverlay(overlay)
            }
        }
    }
}
