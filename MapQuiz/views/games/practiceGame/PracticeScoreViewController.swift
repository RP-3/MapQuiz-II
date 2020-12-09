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
    @IBOutlet weak var correct: UILabel!
    @IBOutlet weak var wrong: UILabel!
    @IBOutlet weak var revealed: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let state = session.currentGameState()
        correctCount.text = "\(state.itemsHandled - state.revealed)"
        wrongCount.text = "\(state.misses)"
        revealedCount.text = "\(state.revealed)"
        summaryLabel.text = "Out of \(state.itemCount) \(session.challengeSet.collectionDescriptor()), you got:"
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

        [correctCount, wrongCount, revealedCount].forEach { $0?.font = UIConstants.amaticBold(size: 40) }
        [correct, wrong, revealed].forEach { $0.font = UIConstants.amaticBold(size: 28) }
        summaryLabel.font = UIConstants.amaticBold(size: 28)
    }

    @objc func back(sender: UIBarButtonItem) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[0], animated: true)
    }
}
