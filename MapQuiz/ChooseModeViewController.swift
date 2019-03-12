//
//  ChooseModeViewController.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import UIKit

class ChooseModeViewController: UIViewController {

    public var continent: Continent!
    @IBOutlet weak var challengeButton: UIButton!
    @IBOutlet weak var practiceButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        challengeButton.titleLabel?.font = UIConstants.amaticBold(size: 28)
        practiceButton.titleLabel?.font = UIConstants.amaticBold(size: 28)
    }

    @IBAction func selectPracticeMode(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        setFont()

        let vc = self.storyboard!.instantiateViewController(withIdentifier: "PracticeViewController") as! PracticeViewController
        vc.continent = continent
        self.navigationController?.pushViewController(vc, animated: true)
    }


    @IBAction func selectChallengeMode(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "Pause"
        navigationItem.backBarButtonItem = backItem
        setFont()

        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ChallengeViewController") as! ChallengeViewController
        vc.continent = continent
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func setFont(){
        navigationItem.backBarButtonItem?.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)],
            for: .normal
        )
    }
}
