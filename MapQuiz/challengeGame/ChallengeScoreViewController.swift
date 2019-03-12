//
//  ChallengeScoreViewController.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import UIKit

class ChallengeScoreViewController: UIViewController {

    public var session: ChallengeSession!

    @IBOutlet weak var winLoseMessage: UILabel!
    @IBOutlet weak var winLoseImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = newBackButton

        winLoseMessage.font = UIConstants.amaticBold(size: 28)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)],
            for: .normal
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let endState = session.currentGameState()

        let countryCount = endState.countryCount
        let timeDifference = Int(session.endTime!.timeIntervalSince(session.startTime!))
        let timing = UIConstants.format(time: timeDifference)

        if endState.countriesHandled == endState.countryCount {
            winLoseImage.image = UIImage(named: "mountain")
            winLoseMessage.text = "You made it! You got all \(countryCount) countries in \(timing)!"
        }
        else if endState.livesRemaining <= 0 { // ran out of lives
            winLoseImage.image = UIImage(named: "wrong")
            winLoseMessage.text = "All your lives are gone! You got \(endState.countriesHandled) countries out of \(countryCount) in \(timing) minutes"
        }
        else { // ran out of time
            winLoseImage.image = UIImage(named: "wrong")
            winLoseMessage.text = "Time up! You got \(endState.countriesHandled) countries out of \(countryCount)"
        }
    }

    @objc func back(sender: UIBarButtonItem) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[0], animated: true)
    }
}
