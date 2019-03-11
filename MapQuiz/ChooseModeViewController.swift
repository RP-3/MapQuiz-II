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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func selectPracticeMode(_ sender: Any) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "PracticeViewController") as! PracticeViewController
        vc.continent = continent
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
