//
//  ChooseModeViewController.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 11/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import UIKit

class ChooseModeViewController: UIViewController {

    public var challengeSet: ChallengeSet!
    @IBOutlet weak var challengeButton: UIButton!
    @IBOutlet weak var practiceButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var challengeDescriptionLine1: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var nullOrErrorStateView: UIView!
    @IBOutlet weak var dataStateView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var leaderboardButton: UIButton!

    // data state labels
    @IBOutlet weak var qualifyingPlayersLabel: UILabel!
    @IBOutlet weak var lastChallengeTiming: UILabel!
    @IBOutlet weak var bestChallengeTiming: UILabel!
    @IBOutlet weak var bestScoreHeart1: UIImageView!
    @IBOutlet weak var bestScoreHeart2: UIImageView!
    @IBOutlet weak var lastScoreHeart1: UIImageView!
    @IBOutlet weak var lastScoreHeart2: UIImageView!
    @IBOutlet weak var currentRankLabel: UILabel!

    @IBAction func selectPracticeMode(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        setFont()

        let vc = self.storyboard!.instantiateViewController(withIdentifier: "PracticeViewController") as! PracticeViewController
        vc.challengeSet = challengeSet
        self.navigationController?.pushViewController(vc, animated: true)
    }


    @IBAction func selectChallengeMode(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "Quit"
        navigationItem.backBarButtonItem = backItem
        setFont()

        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ChallengeViewController") as! ChallengeViewController
        vc.challengeSet = challengeSet
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func showLeaderboard(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScoreTabBarController") as! UITabBarController
        if let leaderboard = vc.viewControllers?[0] as? LeaderboardViewController {
            leaderboard.defaultChallengeSet = self.challengeSet
        }
        self.present(vc, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.nullOrErrorStateView.isHidden = false
        self.dataStateView.isHidden = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()

        self.title = challengeSet.title
        self.titleLabel.text = challengeSet.title
        self.titleImage.image = challengeSet.tableCellImage

        let count = String(BoundaryDB.boundedItems(inChallengeSet: challengeSet).count)
        let description = "There are \(count) \(challengeSet.collectionDescriptor) in this quiz."
        self.challengeDescriptionLine1.text = description
        self.emptyLabel.text = "We're just fetching your scores..."

        RegistrationClient.registerDevice() // fire and forget. No-op if already happened.

        RankCache.shared.fetchLatestScores(andExecute: { success in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true

            guard success else {
                self.emptyLabel.text = "We can't fetch your scores because you're not connected to the internet"
                return
            }
            guard let ranking = RankCache.shared.score(for: self.challengeSet) else {
                let title = self.challengeSet.title
                self.emptyLabel.text = "When you complete the map of \(title) on challenge mode you'll see your score here"
                return
            }

            // hide leaderboard button if it doesn't fit
            self.leaderboardButton.isHidden = self.leaderboardButton.frame.intersects(self.currentRankLabel.frame)

            self.nullOrErrorStateView.isHidden = true
            self.dataStateView.isHidden = false
            self.qualifyingPlayersLabel.text = "\(String(ranking.total)) Qualifying Players"
            self.bestChallengeTiming.text = UIConstants.format(milliseconds: ranking.lengthInMs)
            self.bestScoreHeart1.alpha = ranking.livesRemaining < 3 ? 0.2 : 1.0
            self.bestScoreHeart2.alpha = ranking.livesRemaining < 2 ? 0.2 : 1.0
            self.currentRankLabel.attributedText = NSAttributedString(
                string: String(ranking.rank),
                attributes: UIConstants.attributedText(
                    font: UIConstants.josefinSans(size: 20),
                    color: UIColor(named: "textColour")!,
                    kern: 0
                )
            )
            self.currentRankLabel.isHidden = false

            // everything worked; also display the latest game summary from localstorage
            if let summary = RankCache.shared.fetchGameSummary(for: self.challengeSet) {
                self.lastChallengeTiming.text = UIConstants.format(milliseconds: summary.lengthInMs)
                self.lastScoreHeart1.alpha = summary.livesRemaining < 3 ? 0.2 : 1.0
                self.lastScoreHeart2.alpha = summary.livesRemaining < 2 ? 0.2 : 1.0
            } else { // unless there isn't one, in which case fall back to the best score
                self.lastChallengeTiming.text = UIConstants.format(milliseconds: ranking.lengthInMs)
                self.bestScoreHeart1.alpha = ranking.livesRemaining < 3 ? 0.2 : 1.0
                self.bestScoreHeart2.alpha = ranking.livesRemaining < 2 ? 0.2 : 1.0
            }
        })
    }

    private func setFont(){
        if let btn = navigationItem.backBarButtonItem {
            UIConstants.set(attrs: [NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)], forAllStatesOn: btn)
        }
    }
}
