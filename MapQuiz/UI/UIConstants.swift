//
//  UIConstants.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import UIKit

class UIConstants {

    public static let mapBeige = UIColor(red: 0.99, green: 0.93, blue: 0.9, alpha: 1.0)
    public static let mapRed = UIColor(red: 222.0/255.0, green: 83.0/255.0, blue: 83.0/255.0, alpha: 1.0)
    public static let mapStroke = UIColor(red: 0.15, green: 0.1, blue: 0.01, alpha: 1.0)

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

    public static func format(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        let minutesString = minutes > 0 ? "\(minutes)" : "0"
        let secondsString = (seconds) > 9 ? "\(seconds)" : "0\(seconds)"
        return "\(minutesString):\(secondsString)"
    }

    public static func format(milliseconds: Int) -> String{
        let minutes = (milliseconds / 1000) / 60
        let seconds = (milliseconds / 1000) - (minutes * 60)
        let remainingMilliseconds = milliseconds % 1000
        let minuteString: String = {
            if minutes == 0 { return "00" }
            if minutes < 10 { return "0\(String(minutes))"}
            return String(minutes)
        }()
        let secondString: String = {
            if seconds == 0 { return "00" }
            if seconds < 10 { return "0\(String(seconds) )"}
            return String(seconds)
        }()
        let msString: String = {
            if remainingMilliseconds == 0 { return "000" }
            if remainingMilliseconds < 10 { return "00\(String(remainingMilliseconds))"}
            if remainingMilliseconds < 100 { return "0\(String(remainingMilliseconds))"}
            return String(remainingMilliseconds)
        }()
        return "\(minuteString):\(secondString).\(msString)"
    }
}
