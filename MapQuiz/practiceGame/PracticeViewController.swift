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

    private let BLUE = UIColor(red: 0.3, green: 0.5, blue: 1, alpha: 1)
    private let GREEN = UIColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0)
    private let RED = UIColor(red: 0.8, green: 0.2, blue: 0.5, alpha: 1.0)

    @IBOutlet weak var worldMap: MKMapView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var revealButton: UIBarButtonItem!
    @IBOutlet weak var skipButton: UIBarButtonItem!

    // MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        worldMap.delegate = mapDelegate
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)]
        revealButton.setTitleTextAttributes([NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)], for: .normal)
        skipButton.setTitleTextAttributes([NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)], for: .normal)
        instructionLabel.font = UIConstants.amaticBold(size: 24)
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
        instructionLabel.backgroundColor = BLUE
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false // disable popViewController by swiping
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        worldMap.overlays.forEach(worldMap.removeOverlay)
        if let gr = gestureRecognizer { self.view.removeGestureRecognizer(gr) }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    // MARK: Rendering
    private func renderGameState(){
        let gameState = session.currentGameState()

        self.title = String("\(gameState.countriesHandled) / \(gameState.countryCount)")

        if let countryToFind = gameState.currentCountryName {
            instructionLabel.text = "Find \(countryToFind)"
        }

        if session.finished() {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PracticeScoreViewController") as! PracticeScoreViewController
            vc.session = session
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: Actions
    @IBAction func reveal(_ sender: Any) {
        let currentCountryName = session.currentGameState().currentCountryName ?? ""
        guard let overlap = worldMap.overlays.filter({ $0.title == currentCountryName }).first else { return }
        worldMap.setRegion(MKCoordinateRegion(overlap.boundingMapRect), animated: true)
        removeOverlayFor(countryName: currentCountryName)
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

        let (country, guessOutcome) = session.guess(coords: coords)

        switch guessOutcome {
        case .correct:
            removeOverlayFor(countryName: country!.name)
            SoundBoard.play(.yep)
            instructionLabel.backgroundColor = GREEN
        case .wrong:
            SoundBoard.play(.nope)
            instructionLabel.backgroundColor = RED
        case .fatFingered:
            break
        }

        renderGameState()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { self.instructionLabel.backgroundColor = self.BLUE }
    }

    // MARK: Overlays
    private func removeOverlayFor(countryName: String){
        let overlays = worldMap.overlays.filter({ $0.title == countryName })
        overlays.forEach(worldMap.removeOverlay)
        let annotation = MKPointAnnotation()
        annotation.coordinate = (overlays.first! as! CustomPolygon).annotation_point
        annotation.title = overlays.first!.title!
        worldMap.addAnnotation(annotation)
    }
}