//
//  ChooseMapViewController.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 8/2/20.
//  Copyright © 2020 Phosphorous Labs. All rights reserved.
//

import UIKit

class ChooseMapViewController: UITableViewController {

    override func viewDidLoad(){
        super.viewDidLoad()
        let nib = UINib.init(nibName: "MapCell", bundle: nil)
        let headerNib = UINib.init(nibName: "MapCellHeader", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "MapCell")
        self.tableView.register(headerNib, forCellReuseIdentifier: "MapCellHeader")
    }

    // MARK: Tableview Delegates
    // MARK: TableView Delegates
    override func numberOfSections(in tableView: UITableView) -> Int { return 2 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : ChallengeSet.allCases.count - 1
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 60)
        let title = section == 0 ? "New: US States" : "Countries of the World"
        return MapCellHeader(frame: frame, title: title)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let challengeSet: ChallengeSet = .usStates
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell") as! MapCell
            cell.set(challengeSet: challengeSet)
            return cell
        } else {
            let challengeSet: ChallengeSet = ChallengeSet.at(index: indexPath.row)
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell") as! MapCell
            cell.set(challengeSet: challengeSet)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
//        let backItem = UIBarButtonItem()
//        backItem.title = LocalizedString("library")
//        let backButtonTextAttributes = RuntimeConstants.avenirNext(size: 14, colour: UIColor.white)
//        let highlightedTextAttributes = RuntimeConstants.avenirNext(size: 14, colour: RuntimeConstants.lightGrey)
//        backItem.setTitleTextAttributes(backButtonTextAttributes, for: .normal)
//        backItem.setTitleTextAttributes(highlightedTextAttributes, for: .highlighted)
//        navigationItem.backBarButtonItem = backItem
//
//        if indexPath.section == 0 {
//            let guide = AudioGuides.shared.allGuides()[indexPath.row]
//            store.dispatch(SetSelectedGuidePack(guide: guide.guidePack))
//            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GuideLanguageViewController") as! GuideLanguageViewController
//            vc.selectedGuidePackAisle = guide
//            navigationController!.pushViewController(vc, animated: true)
//        } else {
//            let hikingMap = OfflineMaps.shared.allMaps()[indexPath.row]
//            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HikingMapViewController") as! HikingMapViewController
//            vc.offlineMap = hikingMap
//            navigationController!.pushViewController(vc, animated: true)
//        }
    }
}
