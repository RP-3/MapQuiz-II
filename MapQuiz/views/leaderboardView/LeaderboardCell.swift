//
//  LeaderboardCell.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 24/1/20.
//  Copyright © 2020 Phosphorous Labs. All rights reserved.
//

import UIKit

class LeaderboardCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var timing: UILabel!
    @IBOutlet weak var heart1: UIImageView!
    @IBOutlet weak var heart2: UIImageView!
    @IBOutlet weak var heart3: UIImageView!

    public func set(scoreRow: NamedRanking) {
        name.text = scoreRow.anonymous ? "\(scoreRow.name) (Anonymous)" : scoreRow.name
        name.alpha = scoreRow.anonymous ? 0.5 : 1

        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        position.text = formatter.string(from: NSNumber(value: scoreRow.rank))

        let milliseconds = scoreRow.lengthInMs
        let minutes = (milliseconds / 1000) / 60
        let seconds = (milliseconds / 1000) - (minutes * 60)
        let remainingMilliseconds = milliseconds % 1000
        timing.text = "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds)).\(String(format: "%03d", remainingMilliseconds))"

        heart3.alpha = scoreRow.livesRemaining < 3 ? 0.2 : 0.7
        heart2.alpha = scoreRow.livesRemaining < 2 ? 0.2 : 0.7
        heart1.alpha = 0.7
    }
}
