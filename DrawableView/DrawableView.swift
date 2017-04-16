//
//  DrawableView.swift
//  DrawableView
//
//  Created by Ethan Schatzline on 4/9/17.
//  Copyright © 2017 Ethan Schatzline. All rights reserved.
//

import UIKit

public protocol DrawableViewDelegate: class {
    // Lets the delegate know that the user has begun or ended drawing
    func setDrawing(_ isDrawing: Bool)
}

private struct Constants {
    static let BoxScaleFactor: CGFloat = 2.0
    static let PointsCountThreshold = 500
}

private typealias ImageCreationRequestIdentifier = Int
private typealias CreationCallback = (ImageCreationResponse) -> Void

private struct ImageCreationResponse {
    let image: UIImage?
    let requestID: ImageCreationRequestIdentifier
}

public class DrawableView: UIView {
    
    // MARK: - Public Properties
    public weak var delegate: DrawableViewDelegate?
    
    public var containsDrawing: Bool {
        return !strokes.isEmpty
    }
    
    public var strokeWidth: CGFloat = 4.0
    public var strokeColor: UIColor = .red
    public var strokeTransparency: CGFloat = 1.0
    
    // MARK: - Private Properties
    fileprivate var strokes: StrokeCollection = StrokeCollection()
    fileprivate let latestStrokes: LatestStrokeCollection = LatestStrokeCollection()
    fileprivate var strokesWaitingForImage: StrokeCollection?
    
    fileprivate var previousStrokesImage: UIImage?
    fileprivate var nextImageCreationRequestId: ImageCreationRequestIdentifier = 0
    fileprivate var pendingImageCreationRequestId: ImageCreationRequestIdentifier?
    
    override public func touchesBegan( _ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.setDrawing(true)
        if let touch = touches.first {
            let point = touch.location(in: self)
            let brush = Brush(strokeWidth: strokeWidth, strokeColor: strokeColor, strokeTransparency: strokeTransparency)
            strokes.newStroke(initialPoint: point, brush: brush)
            latestStrokes.newStroke(initialPoint: point, brush: brush)
        }
    }
    
    override public func touchesMoved( _ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            drawFromTouch(touch)
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.setDrawing(false)
        if let touch = touches.first {
            drawFromTouch(touch)
        }
    }
}

// MARK: - Undo
extension DrawableView {
    public func undo() {
        strokesWaitingForImage = nil
        pendingImageCreationRequestId = nil
        
        guard !strokes.isEmpty else { return }
        
        // Remove the last stroke
        strokes.removeLastStroke()
        latestStrokes.clear()
        
        // Synchronously create an image from all of the strokes and set is as the "back buffer" image so
        // all drawing after this is drawn on top of it
        previousStrokesImage = createImage(from: strokes, size: bounds.size)
        layer.setNeedsDisplay()
    }
}

// MARK: - Drawing
extension DrawableView {
    fileprivate func drawFromTouch(_ touch: UITouch) {
        let point = touch.location(in: self)
        
        if let previousPoint = strokes.lastPoint, let brush = strokes.lastBrush {
            // Add point to the stroke
            // Also check if it is over the threshold to trigger a UIImage request
            strokes.addPointToLastStroke(point)
            latestStrokes.addPointToLastStroke(point)
            
            let overThreshold = latestStrokes.transferrablePointCount >= Constants.PointsCountThreshold
            // Check if number of points is over the threshold in which
            // we create a new "back buffer" image so that we
            // are only ever drawing a set maximum number of points per frame
            if overThreshold {
                // Over the threshold. Figure out which points to create an image out of
                // Since the image request function below is asynchronous,
                // it is possible that it may take longer to create the image than it takes
                // for the user to input the "threshold" number of points again.
                // ASSUMPTION: The threshold count is much larger than the time it takes
                // to create an image for all devices
                let strokesToMakeImage = latestStrokes.splitInTwo(numPoints: latestStrokes.transferrablePointCount)
                let requestID = nextImageCreationRequestId
                
                // Create a callback that clears appropriate data and updates the "back buffer image"
                let imageCreationBlock: CreationCallback = { response in
                    DispatchQueue.main.async {
                        // Check if the request coming back is the latest one we care about
                        if requestID == response.requestID {
                            // Clear out the "strokes waiting for image" and "pending request ID"
                            self.strokesWaitingForImage = nil
                            self.pendingImageCreationRequestId = nil
                            self.previousStrokesImage = response.image
                        }
                    }
                }
                
                pendingImageCreationRequestId = requestID
                strokesWaitingForImage = strokesToMakeImage
                nextImageCreationRequestId += 1
                
                createImageAsynchronously(from: strokesToMakeImage, image: previousStrokesImage, size: bounds.size, requestID: requestID, callback: imageCreationBlock)
            }
            
            redrawLayerInBoundingBoxOfLastLine(previousPoint: previousPoint, point: point, brushWidth: brush.width)
        }
    }
    
    private func redrawLayerInBoundingBoxOfLastLine(previousPoint: CGPoint, point: CGPoint, brushWidth: CGFloat) {
        let subPath = CGMutablePath()
        subPath.move(to: previousPoint)
        subPath.addLine(to: point)
        
        var drawBox = subPath.boundingBox
        drawBox.origin.x -= brushWidth * Constants.BoxScaleFactor
        drawBox.origin.y -= brushWidth * Constants.BoxScaleFactor
        drawBox.size.width += brushWidth * Constants.BoxScaleFactor * 2
        drawBox.size.height += brushWidth * Constants.BoxScaleFactor * 2
        
        layer.setNeedsDisplayIn(drawBox)
    }
    
    override public func draw(_ layer: CALayer, in ctx: CGContext) {
        guard !strokes.isEmpty else { return }
        
        if let img = previousStrokesImage?.cgImage {
            drawImageFlipped(image: img, in: ctx)
        }
        
        strokesWaitingForImage?.draw(in: ctx)
        latestStrokes.draw(in: ctx)
    }
    
    fileprivate func drawImageFlipped(image: CGImage, in context: CGContext) {
        context.saveGState()
        context.translateBy(x: 0.0, y: CGFloat(image.height))
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(image, in: CGRect(x: 0, y: 0, width: CGFloat(image.width), height: CGFloat(image.height)))
        context.restoreGState()
    }
}

// MARK: - Image Creation
extension DrawableView {
    fileprivate func createImage(from strokes: StrokeCollection, image: UIImage? = nil, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        if let cgImage = image?.cgImage {
            drawImageFlipped(image: cgImage, in: context)
        }
        
        strokes.draw(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    fileprivate func createImageAsynchronously(from strokes: StrokeCollection, image: UIImage? = nil, size: CGSize, requestID: ImageCreationRequestIdentifier, callback: @escaping CreationCallback)
    {
        
        DispatchQueue.global(qos: .userInteractive).async {
            let image = self.createImage(from: strokes, image: image, size: size)
            callback(ImageCreationResponse(image: image, requestID: requestID))
        }
    }
}
