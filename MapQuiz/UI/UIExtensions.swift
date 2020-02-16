//
//  UIExtensions.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 16/2/20.
//  Copyright © 2020 Phosphorous Labs. All rights reserved.
//

import UIKit

class UIViewWithDashedLineBorder: UIView {

    override func draw(_ rect: CGRect) {

        let path = UIBezierPath(roundedRect: rect, cornerRadius: 5)

        UIColor.clear.setFill()
        path.fill()

        UIColor(rgb: 0xC4C4C4).setStroke()

        path.lineWidth = 3

        let dashPattern : [CGFloat] = [5, 5]
        path.setLineDash(dashPattern, count: 2, phase: 0)
        path.stroke()
    }
}

extension UIColor {
    convenience init(rgb: Int, alpha: CGFloat=1.0) {
        let blue = CGFloat(rgb & 0xFF)/255.0
        let green = CGFloat(rgb >> 8 & 0xFF)/255.0
        let red = CGFloat(rgb >> 16 & 0xFF)/255.0

        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        assert(alpha >= 0 && alpha <= 1.0, "Invalid alpha component")

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
