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
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mapImage: UIImageView!

    public func set(challengeSet: ChallengeSet){
        self.mapImage.image = challengeSet.tableCellImage

        self.titleLabel.attributedText = NSAttributedString(
            string: challengeSet.title.uppercased(),
            attributes: UIConstants.attributedText(
                font: UIConstants.josefinSansRegular(size: 18),
                color: UIColor(named: "textColour")!,
                kern: 0
            )
        )

        let prefix = BoundaryDB.size(of: challengeSet)
        let suffix = challengeSet.collectionDescriptor
        self.descriptionLabel.attributedText = NSAttributedString(
            string: "\(String(prefix)) \(suffix)",
            attributes: UIConstants.attributedText(
                font: UIConstants.josefinSans(size: 18),
                color: UIColor(named: "textColour")!,
                kern: 0
            )
        )

        self.contentView.layer.cornerRadius = 4
        self.contentView.layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
    }
}
