//
//  MapCellHeader.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 8/2/20.
//  Copyright © 2020 Phosphorous Labs. All rights reserved.
//

import UIKit

class MapCellHeader: UIView {

    convenience init(frame: CGRect, title: String) {
        self.init(frame: frame)

        let label = UILabel()
        label.frame = CGRect.init(x: 20, y: 5, width: self.frame.width-10, height: self.frame.height-10)
        label.attributedText = NSAttributedString(
            string: title.uppercased(),
            attributes: UIConstants.attributedText(
                font: UIConstants.amaticBold(size: 28),
                color: UIColor(named: "textColour")!,
                kern: 4
            )
        )

        self.backgroundColor = .clear
        let blurEffect = UIBlurEffect.init(style: .regular)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.frame = self.bounds
        self.addSubview(bluredView)
        self.addSubview(label)
    }
}
