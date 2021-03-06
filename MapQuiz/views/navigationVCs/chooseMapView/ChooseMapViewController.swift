//
//  ChooseMapViewController.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 8/2/20.
//  Copyright © 2020 Phosphorous Labs. All rights reserved.
//

import UIKit

class ChooseMapViewController: UITableViewController {
    // MARK: Actions
    @IBAction func showScores(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScoreTabBarController") as! UITabBarController
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func showSettings(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.present(vc, animated: true, completion: nil)
    }

    // MARK: Lifecycle methods
    override func viewDidLoad(){
        super.viewDidLoad()

        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)]
        self.title = "MapQuiz"
        RegistrationClient.registerDevice()

        let nib = UINib.init(nibName: "MapCell", bundle: nil)
        let headerNib = UINib.init(nibName: "MapCellHeader", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "MapCell")
        self.tableView.register(headerNib, forCellReuseIdentifier: "MapCellHeader")
    }

    // MARK: Tableview Delegates
    override func numberOfSections(in tableView: UITableView) -> Int { return ChallengeSets.all.count }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChallengeSets.all[section].challengeSets.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 60)
        let title = ChallengeSets.all[section].header
        return MapCellHeader(frame: frame, title: title)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let collection = ChallengeSets.all[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell") as! MapCell
        cell.set(displayItem: collection.challengeSets[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.tableView.deselectRow(at: indexPath, animated: true)

        let backItem = UIBarButtonItem()
        let attrs = UIConstants.attributedText(
            font: UIConstants.amaticBold(size: 24),
            color: UIColor(named: "textColour")!,
            kern: 0
        )
        UIConstants.set(attrs: attrs, forAllStatesOn: backItem)
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem

        let item = ChallengeSets.all[indexPath.section].challengeSets[indexPath.row]
        switch item {
        case let cs as ChallengeSet:
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "ChooseModeViewController") as! ChooseModeViewController
            vc.challengeSet = cs
            self.navigationController?.pushViewController(vc, animated: true)
        case let group as GroupedChallengeSetCollection:
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "ChooseGroupedMapViewController") as! ChooseGroupedMapViewController
            vc.group = group
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            fatalError("Unknown entity subscribed to ChooseGameTableDisplayable protocol")
        }
    }
}
