//
//  ChooseModeViewController.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import UIKit

class ChooseModeViewController: UIViewController {

    public var challengeSet: ChallengeSet!
    @IBOutlet weak var challengeButton: UIButton!
    @IBOutlet weak var practiceButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var challengeDescriptionLine1: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!

    @IBAction func selectPracticeMode(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        setFont()

        let vc = self.storyboard!.instantiateViewController(withIdentifier: "PracticeViewController") as! PracticeViewController
        vc.continent = challengeSet
        self.navigationController?.pushViewController(vc, animated: true)
    }


    @IBAction func selectChallengeMode(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "Quit"
        navigationItem.backBarButtonItem = backItem
        setFont()

        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ChallengeViewController") as! ChallengeViewController
        vc.continent = challengeSet
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = challengeSet.title()
        self.titleLabel.text = challengeSet.title()
        self.titleImage.image = challengeSet.toTableCellImage()

        let count = String(BoundaryDB.boundedItems(inChallengeSet: challengeSet).count)
        let description = "There are \(count) states & territories in \(challengeSet.title())."
        self.challengeDescriptionLine1.text = description

        self.emptyLabel.text = "When you complete the map of \(challengeSet.title()) on challenge mode you'll see your score here"

        RegistrationClient.registerDevice()
    }

    private func setFont(){
        navigationItem.backBarButtonItem?.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)],
            for: .normal
        )
    }
}
