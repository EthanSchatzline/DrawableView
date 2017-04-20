//
//  Stroke.swift
//  DrawableView
//
//  Created by Ethan Schatzline on 4/9/17.
//  Copyright © 2017 Ethan Schatzline. All rights reserved.
//

import UIKit

private struct Constants {
    static let BrushWidthThreshold: CGFloat = 16.0
}

class Stroke {
    
    var points: [CGPoint]
    var brush: Brush
    
    private var lastSmoothPoints: [CGPoint]?
    var smoothPoints: [CGPoint] {
        guard points.count > 2 else { return lastSmoothPoints ?? points }
        
        var smoothPoints: [CGPoint] = lastSmoothPoints ?? []
        for i in 2..<points.count {
            guard let prev2 = points[safe: i - 2],
                let prev1 = points[safe: i - 1],
                let current = points[safe: i] else { continue }
            
            let midPoint1X = (prev1.x + prev2.x) * 0.5
            let midPoint1Y = (prev1.y + prev2.y) * 0.5
            let midPoint1 = CGPoint(x: midPoint1X, y: midPoint1Y)
            let midPoint2X = (current.x + prev1.x) * 0.5
            let midPoint2Y = (current.y + prev1.y) * 0.5
            let midPoint2 = CGPoint(x: midPoint2X, y: midPoint2Y)
            
            let numberOfSegments: Int = (brush.width > Constants.BrushWidthThreshold) ? 2 : 3
            
            var t: CGFloat = 0.0
            let step: CGFloat = 1.0 / CGFloat(numberOfSegments)
            for _ in 0..<numberOfSegments {
                let x = (midPoint1.x * pow(1 - t, 2)) + ((2.0 * (1 - t) * t) * prev1.x) + (midPoint2.x * (t * t))
                let y = (midPoint1.y * pow(1 - t, 2)) + ((2.0 * (1 - t) * t) * prev1.y) + (midPoint2.y * (t * t))
                let newPoint = CGPoint(x: x, y: y)
                smoothPoints.append(newPoint)
                t += step
            }
            
            smoothPoints.append(midPoint2)
        }
        // We need to leave last 2 points for next draw
        points = Array(points.suffix(2))
        lastSmoothPoints = smoothPoints
        return smoothPoints
    }
    
    init(point: CGPoint, brush: Brush) {
        self.points = [point]
        self.brush = brush
    }
    
    func drawPath(in ctx: CGContext) {
        let pointsToDraw = smoothPoints
        guard let firstPoint = pointsToDraw.first else { return }
        
        ctx.setLineCap(.round)
        ctx.setLineWidth(brush.width)
        ctx.setStrokeColor(brush.color.withAlphaComponent(brush.transparency).cgColor)
        ctx.beginPath()
        
        var lastPoint = firstPoint
        for point in pointsToDraw {
            ctx.move(to: lastPoint)
            ctx.addLine(to: point)
            lastPoint = point
        }
        
        ctx.strokePath()
    }
}

extension Stroke: Equatable {}
func ==(lhs: Stroke, rhs: Stroke) -> Bool {
    let brushesEqual = (lhs.brush == rhs.brush)
    let pointsEqual = (lhs.points == rhs.points)
    let smoothPointsEqual = (lhs.smoothPoints == rhs.smoothPoints)
    return brushesEqual && pointsEqual && smoothPointsEqual
}
