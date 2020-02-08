//
//  MapCell.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 8/2/20.
//  Copyright © 2020 Phosphorous Labs. All rights reserved.
//

import UIKit

class MapCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mapImage: UIImageView!

    public func set(challengeSet: ChallengeSet){
        self.titleLabel.text = challengeSet.title().uppercased()
        self.mapImage.image = challengeSet.toTableCellImage()

        self.contentView.layer.cornerRadius = 4
        self.contentView.layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
    }
}
