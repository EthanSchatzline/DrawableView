//
//  CGPoint+Distance.swift
//  DrawableView
//
//  Created by Ethan Schatzline on 4/14/17.
//  Copyright © 2017 Ethan Schatzline. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
    func distance(to otherPoint: CGPoint) -> CGFloat {
        return sqrt(pow(otherPoint.x - x, 2) + pow(otherPoint.y - y, 2))
    }
}
