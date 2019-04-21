//
//  ScoreViewController.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/4/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let refreshControl = UIRefreshControl()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var coverView: UIView!

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: StoreReviewController.safelyRequestReview)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        let nib = UINib(nibName: "ScoreTableViewCell", bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: "ScoreTableViewCell")

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
            refreshControl.addTarget(self, action: #selector(refreshTableData), for: .valueChanged)
            refreshControl.attributedTitle = NSAttributedString(string: "Fetching latest scores ...", attributes: [:])
        }
        else {
            tableView.addSubview(refreshControl)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTableData(self)
    }

    @objc func refreshTableData(_ sender: Any){
        self.headerLabel.text = "Top Scores for \(RankCache.shared.monthString)"

        RankCache.shared.fetchLatestScores(andExecute: { success in
            DispatchQueue.main.async {
                if success {
                    self.tableView.reloadData()
                    self.headerLabel.text = "Top Scores for \(RankCache.shared.monthString)"
                }
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            }
        })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if RankCache.shared.ranking.count > 0 { coverView.isHidden = true }
        return RankCache.shared.ranking.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RankCache.shared.ranking[section].1.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreTableViewCell") as? ScoreTableViewCell ?? ScoreTableViewCell()
        cell.setup(ranking: RankCache.shared.ranking[indexPath.section].1[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let continentName: String = {
            switch RankCache.shared.ranking[section].0 {
            case .africa: return "Africa"
            case .asia: return "Asia"
            case .europe: return "Europe"
            case .northAmerica: return "North America"
            case .southAmerica: return "South America"
            case .oceania: return "Oceania"
            }
        }()

        let headerView = UIView()
        headerView.backgroundColor = UIColor.lightGray

        let headerLabel = UILabel(frame: CGRect(
            x: 10,
            y: 0,
            width:tableView.bounds.size.width,
            height: tableView.bounds.size.height
        ))
        headerLabel.font = UIConstants.amatic(size: 22)
        headerLabel.textColor = UIColor.black
        headerLabel.text = "\(continentName) (\(RankCache.shared.ranking[section].1[0].total) games played world-wide)"
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)

        return headerView
    }
}
