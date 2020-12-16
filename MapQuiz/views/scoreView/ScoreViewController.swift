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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 90
        tableView.separatorStyle = .singleLine
        let nib = UINib(nibName: "ScoreTableViewCell", bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: "ScoreTableViewCell")

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
            refreshControl.tintColor = .black
            refreshControl.addTarget(self, action: #selector(refreshTableData), for: .valueChanged)
            refreshControl.attributedTitle = NSAttributedString(string: "Fetching latest scores ...", attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.black
            ])
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
        self.headerLabel.text = "Your Ranks for \(RankCache.shared.monthString)"

        RankCache.shared.fetchLatestScores(andExecute: { success in
            DispatchQueue.main.async {
                if success {
                    self.tableView.reloadData()
                    self.headerLabel.text = "Your Ranks for \(RankCache.shared.monthString)"
                }
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            }
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if RankCache.shared.ranking.count > 0 { coverView.isHidden = true }
        return RankCache.shared.ranking.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreTableViewCell") as? ScoreTableViewCell ?? ScoreTableViewCell()
        let (challengeSet, ranking) = RankCache.shared.ranking[indexPath.row]
        cell.setup(ranking: ranking[0], challengeSet: challengeSet)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
