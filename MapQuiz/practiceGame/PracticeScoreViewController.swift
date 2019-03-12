//
//  PracticeScoreViewController.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import UIKit

class PracticeScoreViewController: UIViewController {

    public var session: PracticeSession!
    @IBOutlet weak var correctCount: UILabel!
    @IBOutlet weak var wrongCount: UILabel!
    @IBOutlet weak var revealedCount: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let state = session.currentGameState()
        correctCount.text = "\(state.countriesHandled)"
        wrongCount.text = "\(state.misses)"
        revealedCount.text = "\(state.revealed)"
        summaryLabel.text = "Out of \(state.countryCount) countries, you got:"
    }
}
