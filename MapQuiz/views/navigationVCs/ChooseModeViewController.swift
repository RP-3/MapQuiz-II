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
    private var localScoreExists = false
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
        vc.continent = challengeSet
        self.navigationController?.pushViewController(vc, animated: true)
    }


    @IBAction func selectChallengeMode(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "Quit"
        navigationItem.backBarButtonItem = backItem
        setFont()

        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ChallengeViewController") as! ChallengeViewController
        vc.continent = challengeSet
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func showLeaderboard(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScoreTabBarController") as! UITabBarController
        if let leaderboard = vc.viewControllers?[0] as? LeaderboardViewController {
            leaderboard.defaultContinent = self.challengeSet
        }
        self.present(vc, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.nullOrErrorStateView.isHidden = false
        self.dataStateView.isHidden = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()

        self.title = challengeSet.title()
        self.titleLabel.text = challengeSet.title()
        self.titleImage.image = challengeSet.toTableCellImage()
        self.localScoreExists = false // set up a deliberate race. If the score exists locally this will be set to true
        // otherwise we'll use the asynchronously fetched one

        let count = String(BoundaryDB.boundedItems(inChallengeSet: challengeSet).count)
        let description = "There are \(count) states & territories in \(challengeSet.title())."
        self.challengeDescriptionLine1.text = description
        self.emptyLabel.text = "We're just fetching your scores..."

        RegistrationClient.registerDevice()

        RankCache.shared.fetchLatestScores(andExecute: { success in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true

            guard success else {
                self.emptyLabel.text = "We can't fetch your scores because you're not connected to the internet"
                return
            }
            guard let ranking = RankCache.shared.score(for: self.challengeSet) else {
                let title = self.challengeSet.title()
                self.emptyLabel.text = "When you complete the map of \(title) on challenge mode you'll see your score here"
                return
            }

            // hide leaderboard button if it doesn't fit
            self.leaderboardButton.isHidden = self.leaderboardButton.frame.intersects(self.currentRankLabel.frame)

            self.nullOrErrorStateView.isHidden = true
            self.dataStateView.isHidden = false
            self.qualifyingPlayersLabel.text = "\(String(ranking.total)) Qualifying Players"
            self.bestChallengeTiming.text = ranking.formattedLength()
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

            if !self.localScoreExists {
                self.setLatestScore(using: LocalRanking(
                    livesRemaining: ranking.livesRemaining,
                    lengthInMs: ranking.lengthInMs)
                )
            }
        })

        if let localScore = RankCache.shared.fetchRanking(for: self.challengeSet) {
            setLatestScore(using: localScore)
            self.localScoreExists = true
        }
    }

    private func setLatestScore(using localScore: LocalRanking) {
        self.lastChallengeTiming.text = localScore.formattedLength()
        self.lastScoreHeart1.alpha = localScore.livesRemaining < 3 ? 0.2 : 1.0
        self.lastScoreHeart2.alpha = localScore.livesRemaining < 2 ? 0.2 : 1.0
    }

    private func setFont(){
        navigationItem.backBarButtonItem?.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIConstants.amaticBold(size: 24)],
            for: .normal
        )
    }
}
