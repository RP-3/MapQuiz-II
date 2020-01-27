//
//  ViewController.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import UIKit

class ContinentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)]
        self.title = "Pick a continent"
        RegistrationClient.registerDevice()
    }

    @IBAction func selectNorthAmerica(_ sender: Any) { pushViewController(challengeSet: .northAmerica) }
    @IBAction func selectSouthAmerica(_ sender: Any) { pushViewController(challengeSet: .southAmerica) }
    @IBAction func selectAfrica(_ sender: Any) { pushViewController(challengeSet: .africa) }
    @IBAction func selectAsia(_ sender: Any) { pushViewController(challengeSet: .asia) }
    @IBAction func selectOceania(_ sender: Any) { pushViewController(challengeSet: .oceania) }
    @IBAction func selectEurope(_ sender: Any) { pushViewController(challengeSet: .europe) }
    @IBAction func selectUSStates(_ sender: Any) { pushViewController(challengeSet: .usStates) }
    @IBAction func showScores(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScoreTabBarController") as! UITabBarController
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func showProfile(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.present(vc, animated: true, completion: nil)
    }

    private func pushViewController(challengeSet: ChallengeSet){
        let backItem = UIBarButtonItem()
        backItem.title = "Continent"
        navigationItem.backBarButtonItem = backItem
        navigationItem.backBarButtonItem?.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)],
            for: .normal
        )

        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ChooseModeViewController") as! ChooseModeViewController
        vc.continent = challengeSet
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

