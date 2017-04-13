//
//  Stroke.swift
//  DrawableView
//
//  Created by Ethan Schatzline on 4/9/17.
//  Copyright © 2017 Ethan Schatzline. All rights reserved.
//

import UIKit

class Stroke {
    
    var points: [CGPoint]
    var brush: Brush
    
    init(point: CGPoint, brush: Brush) {
        self.points = [point]
        self.brush = brush
    }
}
