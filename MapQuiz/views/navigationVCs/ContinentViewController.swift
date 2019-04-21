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
        ScoreAPIClient.registerDevice()
    }

    @IBAction func selectNorthAmerica(_ sender: Any) { pushViewController(continent: .northAmerica) }
    @IBAction func selectSouthAmerica(_ sender: Any) { pushViewController(continent: .southAmerica) }
    @IBAction func selectAfrica(_ sender: Any) { pushViewController(continent: .africa) }
    @IBAction func selectAsia(_ sender: Any) { pushViewController(continent: .asia) }
    @IBAction func selectOceania(_ sender: Any) { pushViewController(continent: .oceania) }
    @IBAction func selectEurope(_ sender: Any) { pushViewController(continent: .europe) }
    @IBAction func showScores(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScoreViewController") as! ScoreViewController
        self.present(vc, animated: true, completion: nil)
    }

    private func pushViewController(continent: Continent){
        let backItem = UIBarButtonItem()
        backItem.title = "Continent"
        navigationItem.backBarButtonItem = backItem
        navigationItem.backBarButtonItem?.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)],
            for: .normal
        )

        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ChooseModeViewController") as! ChooseModeViewController
        vc.continent = continent
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

