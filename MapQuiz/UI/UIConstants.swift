//
//  UIConstants.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import UIKit

class UIConstants {

    public static func amatic(size: CGFloat) -> UIFont {
        return UIFont(name: "AmaticSC-Regular", size: size)!
    }

    public static func amaticBold(size: CGFloat) -> UIFont {
        return UIFont(name: "AmaticSC-Bold", size: size)!
    }

    public static func josefinSans(size: CGFloat) -> UIFont {
        return UIFont(name: "JosefinSans-Light", size: size)!
    }

    public static func josefinSansRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "JosefinSans-Regular", size: size)!
    }

    public static func attributedText(font: UIFont, color: UIColor, kern: NSNumber) -> [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.kern: kern
        ]
    }

    public static func set(attrs: [NSAttributedString.Key: Any], forAllStatesOn btn: UIBarButtonItem) {
        let states: [UIControl.State] = [.disabled, .focused, .highlighted, .normal]
        for state in states {
            btn.setTitleTextAttributes(attrs, for: state)
        }
    }

    public static func format(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        let minutesString = minutes > 0 ? "\(minutes)" : "0"
        let secondsString = (seconds) > 9 ? "\(seconds)" : "0\(seconds)"
        return "\(minutesString):\(secondsString)"
    }
}
