//
//  Brush.swift
//  DrawableView
//
//  Created by Ethan Schatzline on 4/9/17.
//  Copyright © 2017 Ethan Schatzline. All rights reserved.
//

import UIKit

class Brush {
    
    let width: CGFloat
    let color: UIColor
    let transparency: CGFloat
    
    init(strokeWidth: CGFloat, strokeColor: UIColor, strokeTransparency: CGFloat) {
        self.width = strokeWidth
        self.color = strokeColor
        self.transparency = strokeTransparency
    }
}
