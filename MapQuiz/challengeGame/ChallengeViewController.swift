//
//  ChallengeViewController.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import UIKit
import MapKit

class ChallengeViewController: UIViewController {

    public var continent: Continent!

    private var session: ChallengeSession!
    private let mapDelegate = MapViewDelegate()
    private var gestureRecognizer: UITapGestureRecognizer?
    private weak var timer: Timer?

    private let BLUE = UIColor(red: 0.3, green: 0.5, blue: 1, alpha: 1)
    private let GREEN = UIColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0)
    private let RED = UIColor(red: 0.8, green: 0.2, blue: 0.5, alpha: 1.0)

    @IBOutlet weak var heartOne: UIImageView!
    @IBOutlet weak var heartTwo: UIImageView!
    @IBOutlet weak var heartThree: UIImageView!
    @IBOutlet weak var timeRemaining: UILabel! // TODO: Check if this should trigger an end game
    @IBOutlet weak var worldMap: MKMapView!
    @IBOutlet weak var instructionLabel: UILabel!

    // MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        worldMap.delegate = mapDelegate
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)]
        instructionLabel.font = UIConstants.amaticBold(size: 24)
        timeRemaining.font = UIConstants.amaticBold(size: 24)
        let skipButton = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(skip))
        skipButton.setTitleTextAttributes([NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)], for: .normal)
        self.navigationItem.rightBarButtonItem = skipButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        session = ChallengeSession(continent: continent)

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
        let alert = UIAlertController(title: "Ready?", message: "Hit go to start the game", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "GO", style: .default) { _ in
            self.session.start()
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(
                timeInterval: 1.0,
                target: self,
                selector: #selector(self.tickGameClock),
                userInfo: nil,
                repeats: true
            )
        })
        self.present(alert, animated: true, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        worldMap.overlays.forEach(worldMap.removeOverlay)
        if let gr = gestureRecognizer { self.view.removeGestureRecognizer(gr) }
        timer?.invalidate()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    // MARK: Rendering
    private func renderGameState(){
        let gameState = session.currentGameState()

        self.title = String("\(gameState.countriesHandled) / \(gameState.countryCount)")

        if let countryToFind = gameState.currentCountryName {
            instructionLabel.text = "Find \(countryToFind)"
        }

        if gameState.livesRemaining < 3 { heartThree.alpha = 0.2 }
        if gameState.livesRemaining < 2 { heartTwo.alpha = 0.2 }
        if gameState.livesRemaining < 1 { heartOne.alpha = 0.2 }

        if session.gameOver() {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChallengeScoreViewController") as! ChallengeScoreViewController
            vc.session = session
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc func tickGameClock(){
        let elapsedTime = Date.init().timeIntervalSince(session.startTime!)
        let timeLimit = World.timeLimitFor(continent: continent)
        let secondsRemaining = Int(timeLimit - elapsedTime)

        if secondsRemaining < 0 {
            session.finish()
            timer?.invalidate()
            let alert = UIAlertController(title: "Boo", message: "You ran out of time!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try again", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            })
            self.present(alert, animated: true, completion: nil)
        } else {
            timeRemaining.text = UIConstants.format(time: secondsRemaining)
        }
    }

    // MARK: Actions
    @objc func tapMap(gestureRecognizer: UIGestureRecognizer){
        let coords = worldMap.convert(gestureRecognizer.location(in: worldMap), toCoordinateFrom: worldMap)
        let (country, outcome) = session.guess(coords: coords)

        switch outcome {
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

    @objc func skip(){
        session.skip()
        renderGameState()
        SoundBoard.play(.skip)
    }

    // MARK: Overlays
    private func removeOverlayFor(countryName: String){
        let overlays = worldMap.overlays.filter({ $0.title == countryName })
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
