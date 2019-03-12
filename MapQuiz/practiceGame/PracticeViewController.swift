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

    private weak var session: PracticeSession!
    private let mapDelegate = MapViewDelegate()
    private var gestureRecognizer: UITapGestureRecognizer?

    @IBOutlet weak var worldMap: MKMapView!
    @IBOutlet weak var instructionLabel: UILabel!

    // MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        worldMap.delegate = mapDelegate
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        session = PracticeSessionRegistry.shared.sessionFor(continent: continent)

        session.remainingCountries().forEach { (country: Country) -> Void in
            for landArea in (country.boundary) {
                let overlay = CustomPolygon(guessed: false, lat_long: country.annotation_point, coords: landArea, numberOfPoints: landArea.count )
                overlay.title = country.name
                worldMap.addOverlay(overlay)
            }
        }

        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapMap))
        self.view.addGestureRecognizer(gestureRecognizer!)

        renderGameState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        worldMap.setRegion(World.regionFor(continent: continent), animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        worldMap.overlays.forEach(worldMap.removeOverlay)
        if let gr = gestureRecognizer { self.view.removeGestureRecognizer(gr) }
    }

    // MARK: Rendering
    private func renderGameState(){
        let gameState = session.currentGameState()

        self.title = String("\(gameState.countriesHandled) / \(gameState.countryCount)")

        if let countryToFind = gameState.currentCountryName {
            instructionLabel.text = "Find \(countryToFind)"
            instructionLabel.backgroundColor = UIColor(red: 0.3, green: 0.5, blue: 1, alpha: 1)
        }

        // TODO: Segue to next view controller!
        if session.finished() {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PracticeScoreViewController") as! PracticeScoreViewController
            vc.session = session
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: Actions
    @IBAction func reveal(_ sender: Any) {
        removeOverlayFor(countryName: session.currentGameState().currentCountryName ?? "")
        session.reveal()
        SoundBoard.play(.reveal)
        renderGameState()
    }

    @IBAction func skip(_ sender: Any) {
        session.skip()
        SoundBoard.play(.skip)
        renderGameState()
    }

    @objc func tapMap(gestureRecognizer: UIGestureRecognizer){
        let coords = worldMap.convert(gestureRecognizer.location(in: worldMap), toCoordinateFrom: worldMap)

        if let country = session.guess(coords: coords) {
            removeOverlayFor(countryName: country.name)
            SoundBoard.play(.yep)
        } else {
            SoundBoard.play(.nope)
        }
        renderGameState()
    }

    // MARK: Overlays
    private func removeOverlayFor(countryName: String){
        worldMap.overlays
            .filter { $0.title == countryName }
            .forEach(worldMap.removeOverlay)
    }
}
