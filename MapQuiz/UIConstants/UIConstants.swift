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

    public static func format(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        let minutesString = minutes > 0 ? "\(minutes)" : "0"
        let secondsString = (seconds) > 9 ? "\(seconds)" : "0\(seconds)"
        return "\(minutesString):\(secondsString)"
    }
}
