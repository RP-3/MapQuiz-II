//
//  PracticeScoreViewController.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import UIKit
import MapKit

class PracticeScoreViewController: UIViewController {

    public var session: PracticeSession!
    private let delegate = MapViewDelegate(fill: UIConstants.mapRed, stroke: UIConstants.mapStroke)
    private let wrongThreshold = 3

    @IBOutlet weak var worldMap: MKMapView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var primaryActionBtn: UIButton!

    @IBAction func primaryActionTapped(_ sender: Any) {
        let navController = self.navigationController!
        let storyboard = self.storyboard!
        let shouldChallenge = session.itemsMishandled.count < wrongThreshold
        let challengeSet = session.challengeSet

        for controller in navController.viewControllers as Array {
            if controller.isKind(of: ChooseModeViewController.self) {
                _ =  self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }

        if shouldChallenge {
            let vc = storyboard.instantiateViewController(withIdentifier: "ChallengeViewController") as! ChallengeViewController
            vc.challengeSet = challengeSet
            navController.pushViewController(vc, animated: true)
        } else {
            let vc = storyboard.instantiateViewController(withIdentifier: "PracticeViewController") as! PracticeViewController
            vc.challengeSet = challengeSet
            navController.pushViewController(vc, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMessaging()

        session.itemsMishandled.forEach { (name: String, item: BoundedItem) -> Void in
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

        worldMap.overlays.forEach { (overlay: MKOverlay) -> Void in
            guard let overlay = overlay as? CustomPolygon else { return }
            let annotation = MKPointAnnotation()
            annotation.coordinate = overlay.annotation_point
            annotation.title = overlay.title!
            worldMap.addAnnotation(annotation)
        }
    }

    func setupMessaging() {
        let correct = session.itemsHandled.count
        let wrong = session.itemsMishandled.count
        let fraction = "\(correct) / \(correct + wrong)"

        primaryActionBtn.setTitle("RETRY", for: .normal)

        if correct == 0 {
            summaryLabel.text = "Whups, you got \(fraction)."
            detailLabel.text = "Gotta start somewhere! Take a few seconds to learn just one or two you got wrong"
        }
        else if wrong < wrongThreshold {
            summaryLabel.text = "Congrats 🎉 You got \(fraction)!"
            detailLabel.text = "You know this one pretty well. Ready for a challenge?"
            primaryActionBtn.setTitle("CHALLENGE ME", for: .normal)
        }
        else {
            let score = (Float(correct) / Float(correct + wrong)) * 100
            switch score {
            case 0..<20:
                summaryLabel.text = "Good start! You got \(fraction) 👍"
                detailLabel.text = "Take a minute to learn a few more that you missed"
            case 20..<50:
                summaryLabel.text = "Solid! You got \(fraction) 🙌"
                detailLabel.text = "Keep up the momentum and study a few more"
            case 50..<70:
                summaryLabel.text = "Getting there! You got \(fraction)."
                detailLabel.text = "Learn, test, rinse, repeat 🤩"
            default:
                summaryLabel.text = "Impressive! You got \(fraction)"
                detailLabel.text = "You're almost ready for a challenge! Keep it up 🥳"
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        worldMap.setRegion(session.challengeSet.region, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = newBackButton

        navigationItem.leftBarButtonItem?.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)],
            for: .normal
        )

        worldMap.delegate = delegate
    }

    @objc func back(sender: UIBarButtonItem) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[0], animated: true)
    }
}
