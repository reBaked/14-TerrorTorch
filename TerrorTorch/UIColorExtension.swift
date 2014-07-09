//
//  UIColor+Hex.swift
//  TerrorTorch
//
//  Created by Michael Honaker on 7/8/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexColor: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hexColor & 0xFF0000) >> 16) / 255.0;
        let g = CGFloat((hexColor & 0x00FF00) >> 8) / 255.0;
        let b = CGFloat((hexColor & 0x0000FF)) / 255.0;
        self.init(red:r, green:g, blue:b, alpha:alpha);
    }
}