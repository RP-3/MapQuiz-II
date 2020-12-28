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
        if let btn = navigationItem.leftBarButtonItem {
            let attrs = [NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)]
            UIConstants.set(attrs: attrs, forAllStatesOn: btn)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let endState = session.currentGameState()

        let itemCount = endState.itemCount
        let timeDifference = Int(session.endTime!.timeIntervalSince(session.startTime!))
        let timing = UIConstants.format(time: timeDifference)
        let units = session.challengeSet.collectionDescriptor

        if endState.itemsHandled == endState.itemCount {
            winLoseImage.image = UIImage(named: "mountain")
            winLoseMessage.text = "You made it! You got all \(itemCount) \(units) in \(timing)!"
            StoreReviewController.markChallengeCompleted()
        }
        else if endState.livesRemaining <= 0 { // ran out of lives
            winLoseImage.image = UIImage(named: "wrong")
            winLoseMessage.text = "All your lives are gone! You got \(endState.itemsHandled) \(units) out of \(itemCount) in \(timing) minutes"
        }
        else { // ran out of time
            winLoseImage.image = UIImage(named: "wrong")
            winLoseMessage.text = "Time up! You got \(endState.itemsHandled) \(units) out of \(itemCount)"
        }
    }

    @objc func back(sender: UIBarButtonItem) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: ChooseModeViewController.self) {
                _ =  self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
}
