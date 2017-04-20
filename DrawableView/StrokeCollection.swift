//
//  StrokeCollection.swift
//  DrawableView
//
//  Created by Ethan Schatzline on 4/9/17.
//  Copyright © 2017 Ethan Schatzline. All rights reserved.
//

import UIKit

class StrokeCollection {
    
    fileprivate var strokes: [Stroke] = []
    private(set) var totalPointCount = 0
    
    var strokeCount: Int {
        return strokes.count
    }
    
    var isEmpty: Bool {
        return strokes.isEmpty
    }
    
    var lastStroke: Stroke? {
        return strokes.last
    }
    
    var lastPoint: CGPoint? {
        return strokes.last?.points.last
    }
    
    var lastBrush: Brush? {
        return strokes.last?.brush
    }
    
    fileprivate var lastStrokePointCount: Int {
        return strokes.last?.points.count ?? 0
    }
    
    func newStroke(initialPoint: CGPoint, brush: Brush) {
        let stroke = Stroke(point: initialPoint, brush: brush)
        stroke.points.append(initialPoint)
        stroke.points.append(initialPoint)
        strokes.append(stroke)
        totalPointCount += stroke.points.count
    }
    
    func addPoint(_ point: CGPoint) {
        guard let lastStroke = lastStroke else { return }
        
        if let previousPoint = lastStroke.points.last {
            let threshold: CGFloat = 1.5
            if previousPoint.distance(to: point) <= threshold { return }
        }
        
        addPointToLastStroke(point, stroke: lastStroke)
    }
    
    fileprivate func addPointToLastStroke(_ point: CGPoint, stroke: Stroke) {
        stroke.points.append(point)
        totalPointCount += 1
    }
    
    func removeLastStroke() {
        if let removedStroke = strokes.popLast() {
            totalPointCount -= removedStroke.points.count
        }
    }
    
    func draw(in context: CGContext) {
        for stroke in strokes {
            stroke.drawPath(in: context)
        }
    }
    
    func clear() {
        strokes.removeAll()
        totalPointCount = 0
    }
    
    func splitInTwo(numPoints: Int) -> StrokeCollection {
        let newCollection = StrokeCollection()
        
        // Early exit if empty
        guard totalPointCount > 0 else { return newCollection }
        
        // Can't transfer more than total point count
        var pointsLeft = min(numPoints, totalPointCount)
        
        // Check if more points to transferring
        while pointsLeft > 0 {
            guard let strokeToTransferFrom = strokes.first else { break }
            
            // See if transferring the whole stroke
            let strokePointCount = strokeToTransferFrom.points.count
            if strokePointCount < pointsLeft {
                // Just remove the stroke and transfer it to new collection. Decrease the points left and the total point count
                strokes.removeFirst()
                newCollection.strokes.append(strokeToTransferFrom)
                newCollection.totalPointCount += strokePointCount
                totalPointCount -= strokePointCount
                pointsLeft -= strokePointCount
            } else {
                // Potentially "splitting" the stroke.
                let strokeBeforeSplit = Stroke(point: CGPoint.zero, brush: strokeToTransferFrom.brush) // Initial point doesn't matter
                let pointsBeforeSplit = Array(strokeToTransferFrom.points.prefix(pointsLeft))
                
                // Have the new stroke collection contain a stroke
                // with all of the points before the split
                strokeBeforeSplit.points = pointsBeforeSplit
                newCollection.strokes.append(strokeBeforeSplit)
                
                // If the "strokeToTransferFrom" is the last stroke, or if "strokeToTransferFrom" is
                // being split in the middle (defined as 'not at the end'), then duplicate the point at
                // which the split occurs so that the two paths drawn by the split stroke overlap
                let duplicateSplitPoint = (strokes.count == 1) || (pointsLeft < strokePointCount)
                let pointsToDrop = pointsLeft - (duplicateSplitPoint ? 1 : 0) // subtract 1 here to duplicate the point of split
                let pointsAfterSplit = Array(strokeToTransferFrom.points.dropFirst(pointsToDrop))
                
                // Set the new points for the
                // strokeToTransferFrom (since it is now split)
                strokeToTransferFrom.points = pointsAfterSplit
                
                // Adjust point counts
                newCollection.totalPointCount += pointsLeft
                totalPointCount -= pointsToDrop
                pointsLeft = 0
            }
        }
        
        return newCollection
    }
}

class LatestStrokeCollection: StrokeCollection {
    
    // A point is considered "transferrable" if
    // it is being drawn by an opaque brush
    // OR if it is not in the last stroke
    private(set) var transferrablePointCount: Int = 0
    
    private var pointsOfLastStrokeAreTransferrable: Bool {
        return (lastBrush?.transparency ?? 0.0) >= 1.0
    }
    
    override func newStroke(initialPoint: CGPoint, brush: Brush) {
        // Check if a semi-transprent brush is used for the latest stroke
        // if so, those points are now "transferrable" since
        // that brush will no longer be the latest stroke
        var newTransferrablePoints = !pointsOfLastStrokeAreTransferrable ? lastStrokePointCount : 0
        super.newStroke(initialPoint: initialPoint, brush: brush)
        
        // See if need to include the new stroke's initial point too
        // Include if the brush's transparency >= 1.0
        newTransferrablePoints += pointsOfLastStrokeAreTransferrable ? lastStrokePointCount : 0
        transferrablePointCount += newTransferrablePoints
    }
    
    override fileprivate func addPointToLastStroke(_ point: CGPoint, stroke: Stroke) {
        super.addPointToLastStroke(point, stroke: stroke)
        
        // See if need to include the this point in "transferrable points"
        // Include if the brush's transparency >= 1.0
        transferrablePointCount += (pointsOfLastStrokeAreTransferrable ? 1 : 0)
    }
    
    override func removeLastStroke() {
        transferrablePointCount -= (pointsOfLastStrokeAreTransferrable ? lastStrokePointCount : 0)
        super.removeLastStroke()
        
        // Also, since there is a new "last stroke", need to check
        // if the points for the new "last stroke" are transferrable or not.
        // If they are not transferrable, then they were included in the transferrablePointCount
        // when they were not the "last stroke", so, adjust count for that
        transferrablePointCount -= (!pointsOfLastStrokeAreTransferrable ? lastStrokePointCount : 0)
    }
    
    override func clear() {
        super.clear()
        transferrablePointCount = 0
    }
    
    override func splitInTwo(numPoints: Int) -> StrokeCollection {
        let newCollection = super.splitInTwo(numPoints: numPoints)
        
        // Recalculate the transferrable point count
        transferrablePointCount = 0
        for stroke in strokes.dropLast() {
            transferrablePointCount += stroke.points.count
        }
        
        transferrablePointCount += (pointsOfLastStrokeAreTransferrable ? lastStrokePointCount : 0)
        return newCollection
    }
}
