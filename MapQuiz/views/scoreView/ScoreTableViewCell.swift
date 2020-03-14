//
//  ScoreTableViewCell.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/4/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import UIKit

class ScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var thirdLife: UIImageView!
    @IBOutlet weak var secondLife: UIImageView!

    public func setup(ranking: Ranking){
        thirdLife.alpha = ranking.livesRemaining < 3 ? 0.2 : 1.0
        secondLife.alpha = ranking.livesRemaining < 2 ? 0.2 : 1.0
        timeLabel.text = ranking.formattedLength()
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        rankLabel.text = formatter.string(from: NSNumber(value: ranking.rank))
    }
    
}
