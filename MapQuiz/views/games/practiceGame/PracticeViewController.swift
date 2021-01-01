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

    public var challengeSet: ChallengeSet!

    private weak var session: PracticeSession!
    private let mapDelegate = MapViewDelegate(guessed: .clear, notGuessed: UIConstants.mapBeige, stroke: UIConstants.mapStroke)
    private var gestureRecognizer: UITapGestureRecognizer?
    private var allRevealed = false

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
        let attrs = [NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)]
        self.navigationController?.navigationBar.titleTextAttributes = attrs
        UIConstants.set(attrs: attrs, forAllStatesOn: revealButton)
        UIConstants.set(attrs: attrs, forAllStatesOn: skipButton)
        instructionLabel.font = UIConstants.amaticBold(size: 24)
        let revealAllButton = UIBarButtonItem(title: "Reveal All", style: .plain, target: self, action: #selector(revealAll))
        UIConstants.set(attrs: attrs, forAllStatesOn: revealAllButton)
        self.navigationItem.rightBarButtonItem = revealAllButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        session = PracticeSessionRegistry.shared.sessionFor(challengeSet: challengeSet)

        session.remainingCountries().forEach { (item: BoundedItem) -> Void in
            for landArea in (item.boundary) {
                let overlay = CustomPolygon(guessed: false, lat_long: item.centroid(), coords: landArea, numberOfPoints: landArea.count )
                overlay.title = item.name
                worldMap.addOverlay(overlay)
            }
            if let radius = World.smallIsland(name: item.name) {
                let circle = MKCircle(center: item.centroid(), radius: radius)
                worldMap.addOverlay(circle)
            }
        }

        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapMap))
        self.view.addGestureRecognizer(gestureRecognizer!)

        renderGameState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        worldMap.setRegion(challengeSet.region, animated: true)
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

        self.title = String("\(gameState.itemsHandled) / \(gameState.itemCount)")

        if let itemToFind = gameState.currentItemName {
            instructionLabel.text = "Find \(itemToFind)"
        }
        else if allRevealed {
            instructionLabel.text = "All countries revealed"
        }

        if session.finished() && !allRevealed {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PracticeScoreViewController") as! PracticeScoreViewController
            vc.session = session
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: Actions
    @IBAction func reveal(_ sender: Any) {
        let currentItemName = session.currentGameState().currentItemName ?? ""
        guard let overlap = worldMap.overlays.filter({ $0.title == currentItemName }).first else { return }
        worldMap.setCenter(overlap.coordinate, animated: true)
        removeOverlayFor(itemName: currentItemName)
        session.reveal()
        EffectsBoard.play(.reveal)
        renderGameState()
    }

    @IBAction func skip(_ sender: Any) {
        session.skip()
        EffectsBoard.play(.skip)
        renderGameState()
    }

    @objc func revealAll(){
        session.remainingCountries().forEach { item in
            removeOverlayFor(itemName: item.name)
            session.reveal()
        }
        EffectsBoard.play(.reveal)
        allRevealed = true
        skipButton.isEnabled = false
        revealButton.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        renderGameState()
    }

    @objc func tapMap(gestureRecognizer: UIGestureRecognizer){
        let coords = worldMap.convert(gestureRecognizer.location(in: worldMap), toCoordinateFrom: worldMap)

        let (item, guessOutcome) = session.guess(coords: coords)

        switch guessOutcome {
        case .correct:
            removeOverlayFor(itemName: item!.name)
            EffectsBoard.play(.yep)
            instructionLabel.backgroundColor = GREEN
        case .wrong:
            EffectsBoard.play(.nope)
            instructionLabel.backgroundColor = RED
        case .fatFingered:
            break
        }

        renderGameState()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { self.instructionLabel.backgroundColor = self.BLUE }
    }

    // MARK: Overlays
    private func removeOverlayFor(itemName: String){
        let overlays = worldMap.overlays.filter({ $0.title == itemName })
        overlays.forEach({ overlay in
            worldMap.removeOverlay(overlay)
            (overlay as! CustomPolygon).userGuessed = true
            worldMap.addOverlay(overlay)
        })
        let annotation = MKPointAnnotation()
        annotation.coordinate = (overlays.first! as! CustomPolygon).annotation_point
        annotation.title = overlays.first!.title!
        worldMap.addAnnotation(annotation)
    }
}
