//
//  ChooseGroupedMapViewController.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 27/12/20.
//  Copyright © 2020 Phosphorous Labs. All rights reserved.
//

import UIKit

class ChooseGroupedMapViewController: UITableViewController {
    var group: GroupedChallengeSetCollection!

    // MARK: Lifecycle methods
    override func viewDidLoad(){
        super.viewDidLoad()

        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)]
        RegistrationClient.registerDevice()

        let nib = UINib.init(nibName: "MapCell", bundle: nil)
        let headerNib = UINib.init(nibName: "MapCellHeader", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "MapCell")
        self.tableView.register(headerNib, forCellReuseIdentifier: "MapCellHeader")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = group.title
    }

    // MARK: Tableview Delegates
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.challengeSets.count
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell") as! MapCell
        cell.set(displayItem: group.challengeSets[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)

        let backItem = UIBarButtonItem()
        backItem.title = group.title
        let attrs = UIConstants.attributedText(
            font: UIConstants.amaticBold(size: 24),
            color: UIColor(named: "textColour")!,
            kern: 0
        )
        UIConstants.set(attrs: attrs, forAllStatesOn: backItem)
        navigationItem.backBarButtonItem = backItem
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ChooseModeViewController") as! ChooseModeViewController
        vc.challengeSet = group.challengeSets[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
