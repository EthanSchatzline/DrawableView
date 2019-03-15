//
//  DrawableView.swift
//  DrawableView
//
//  Created by Ethan Schatzline on 4/9/17.
//  Copyright © 2017 Ethan Schatzline. All rights reserved.
//

import UIKit

public protocol DrawableViewDelegate: class {
    /// Lets the delegate know that the user has begun or ended drawing.
    ///
    /// - Parameters:
    ///     - isDrawing: A boolean representing if the user began or ended drawing.
    ///
    /// - Returns: Void
    func setDrawing(_ isDrawing: Bool)
}

private struct Constants {
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
    
    /// A boolean representing if the DrawableView currently contains a drawing.
    public var containsDrawing: Bool {
        return !strokes.isEmpty
    }
    
    /// An optional UIImage of the current drawing.
    public var image: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// The width of the current brush.
    public var strokeWidth: CGFloat = 4.0
    
    /// The color of the current brush.
    public var strokeColor: UIColor = .red
    
    /// The transparency of the current brush.
    public var strokeTransparency: CGFloat = 1.0
    
    // MARK: - Private Properties
    fileprivate var strokes: StrokeCollection = StrokeCollection()
    fileprivate let latestStrokes: LatestStrokeCollection = LatestStrokeCollection()
    fileprivate var strokesWaitingForImage: StrokeCollection?
    
    fileprivate var previousStrokesImage: UIImage?
    fileprivate var nextImageCreationRequestId: ImageCreationRequestIdentifier = 0
    fileprivate var pendingImageCreationRequestId: ImageCreationRequestIdentifier?
    
    // Set to true to see the bounding box passed to `setNeedsDisplayIn(rect)` when drawing
    fileprivate let isDebugMode: Bool = false
    fileprivate var frameView: UIView?
    fileprivate var undoWasTapped: Bool = false
    
    override public func touchesBegan( _ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.setDrawing(true)
        if let touch = touches.first {
            let point = touch.location(in: self)
            let brush = Brush(width: strokeWidth, color: strokeColor, transparency: strokeTransparency)
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
        drawBackBuffer()
    }
}

// MARK: - Undo
public extension DrawableView {
    /// Removes the last stroke and re-draws to the screen.
    ///
    /// - Returns: Void
    func undo() {
        undoWasTapped = true
        strokesWaitingForImage = nil
        pendingImageCreationRequestId = nil
        
        // Remove the last stroke
        strokes.removeLastStroke()
        latestStrokes.clear()
        
        // Synchronously create an image from all of the strokes and set it as the "back buffer" image so
        // all drawing after this is drawn on top of it
        previousStrokesImage = createImage(from: strokes, size: bounds.size)
        layer.setNeedsDisplay()
    }
    
    func clear() {
        undoWasTapped = false
        strokesWaitingForImage = nil
        pendingImageCreationRequestId = nil
        
        // Remove all strokes
        strokes.clear()
        latestStrokes.clear()
        
        // Synchronously create an image from all of the strokes and set it as the "back buffer" image so
        // all drawing after this is drawn on top of it
        previousStrokesImage = createImage(from: strokes, size: bounds.size)
        layer.setNeedsDisplay()
    }
}

// MARK: - Drawing
extension DrawableView {
    fileprivate func drawFromTouch(_ touch: UITouch) {
        let point = touch.location(in: self)
        
        if let lastStroke = strokes.lastStroke {
            // Check if it is over the threshold and force a break in the current stroke
            let overThreshold = latestStrokes.transferrablePointCount >= Constants.PointsCountThreshold
            if !overThreshold {
                strokes.addPoint(point)
                latestStrokes.addPoint(point)
            }
            
            redrawLayerInBoundingBox(of: lastStroke)
        }
    }
    
    private func redrawLayerInBoundingBox(of stroke: Stroke) {
        let pointsToDraw = Array(stroke.points.suffix(3))
        guard let firstPoint = pointsToDraw.first else { return }
        
        let subPath = CGMutablePath()
        var previousPoint = firstPoint
        for point in pointsToDraw {
            subPath.move(to: previousPoint)
            subPath.addLine(to: point)
            previousPoint = point
        }
        
        var drawBox = subPath.boundingBox
        let brushWidth = stroke.brush.width
        drawBox.origin.x -= brushWidth * 0.5
        drawBox.origin.y -= brushWidth * 0.5
        drawBox.size.width += brushWidth
        drawBox.size.height += brushWidth
        
        if isDebugMode {
            frameView?.removeFromSuperview()
            let newFrameView = UIView(frame: drawBox)
            frameView = newFrameView
            newFrameView.backgroundColor = .clear
            newFrameView.layer.borderColor = UIColor.black.cgColor
            newFrameView.layer.borderWidth = 2
            addSubview(newFrameView)
        }
        
        layer.setNeedsDisplay(drawBox)
    }
    
    override public func draw(_ layer: CALayer, in ctx: CGContext) {
        guard !strokes.isEmpty else { return }
        
        if let img = previousStrokesImage?.cgImage {
            drawImageFlipped(image: img, in: ctx)
        }
        
        strokesWaitingForImage?.draw(in: ctx)
        latestStrokes.draw(in: ctx)
    }
    
    fileprivate func drawBackBuffer() {
        undoWasTapped = false
        let strokesToMakeImage = latestStrokes.splitInTwo(numPoints: latestStrokes.transferrablePointCount)
        let requestID = nextImageCreationRequestId
        
        // Create a callback that clears appropriate data and updates the "back buffer image"
        let imageCreationBlock: CreationCallback = { response in
            DispatchQueue.main.async {
                if self.undoWasTapped {
                    self.drawBackBuffer()
                    return
                }
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
