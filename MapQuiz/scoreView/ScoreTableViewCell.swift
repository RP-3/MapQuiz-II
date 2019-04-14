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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    public func setup(ranking: Ranking){
        thirdLife.alpha = ranking.livesRemaining < 3 ? 0.2 : 1.0
        secondLife.alpha = ranking.livesRemaining < 2 ? 0.2 : 1.0

        let milliseconds = ranking.lengthInMs
        let minutes = (milliseconds / 1000) / 60
        let seconds = (milliseconds / 1000) - (minutes * 60)
        let remainingMilliseconds = milliseconds % 1000
        timeLabel.text = "\(minutes >= 0 ? "" : "0")\(minutes):\(seconds).\(remainingMilliseconds)"

        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        rankLabel.text = formatter.string(from: NSNumber(value: ranking.rank))
    }
    
}
