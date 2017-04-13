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
    
    func drawPath(_ points: [CGPoint], ctx: CGContext) {
        guard let firstPoint = points.first else { return }
        
        ctx.setLineCap(.round)
        ctx.setLineWidth(width)
        ctx.setStrokeColor(color.withAlphaComponent(transparency).cgColor)
        ctx.beginPath()
        
        var lastPoint = firstPoint
        for point in points {
            ctx.move(to: lastPoint)
            ctx.addLine(to: point)
            lastPoint = point
        }
        
        ctx.strokePath()
    }
}
