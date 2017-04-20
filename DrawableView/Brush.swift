//
//  Brush.swift
//  DrawableView
//
//  Created by Ethan Schatzline on 4/9/17.
//  Copyright © 2017 Ethan Schatzline. All rights reserved.
//

import UIKit

struct Brush {
    let width: CGFloat
    let color: UIColor
    let transparency: CGFloat
}

extension Brush: Equatable {}
func ==(lhs: Brush, rhs: Brush) -> Bool {
    let widthEqual = (lhs.width == rhs.width)
    let colorEqual = (lhs.color == rhs.color)
    let transparencyEqual = (lhs.transparency == rhs.transparency)
    return widthEqual && colorEqual && transparencyEqual
}
