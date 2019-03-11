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
        //        TODO: Add AmaticSC-Bold to project
//        self.navigationController?.navigationBar.titleTextAttributes = [
//            NSAttributedString.Key.font: UIFont(name: "AmaticSC-Bold", size: 28)!]
        self.title = "Pick a continent"
    }

    @IBAction func selectNorthAmerica(_ sender: Any) { pushViewController(continent: .northAmerica) }

    @IBAction func selectSouthAmerica(_ sender: Any) { pushViewController(continent: .southAmerica) }

    @IBAction func selectAfrica(_ sender: Any) { pushViewController(continent: .africa) }

    @IBAction func selectAsia(_ sender: Any) { pushViewController(continent: .asia) }

    @IBAction func selectOceania(_ sender: Any) { pushViewController(continent: .oceania) }

    @IBAction func selectEurope(_ sender: Any) { pushViewController(continent: .europe) }

    private func pushViewController(continent: Continent){
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ChooseModeViewController") as! ChooseModeViewController
        vc.continent = continent
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

