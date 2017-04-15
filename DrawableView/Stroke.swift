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
    
    func drawPath(in ctx: CGContext) {
        guard let firstPoint = points.first else { return }
        
        ctx.setLineCap(.round)
        ctx.setLineWidth(brush.width)
        ctx.setStrokeColor(brush.color.withAlphaComponent(brush.transparency).cgColor)
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
