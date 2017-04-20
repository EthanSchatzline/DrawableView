//
//  StrokeCollectionTests.swift
//  DrawableView
//
//  Created by Ethan Schatzline on 4/18/17.
//  Copyright © 2017 Ethan Schatzline. All rights reserved.
//

import XCTest

class StrokeCollectionTests: XCTestCase {
    
    var strokeCollection: StrokeCollection!
    let blackBrush: Brush = Brush(width: 2.0, color: .black, transparency: 1.0)
    
    override func setUp() {
        super.setUp()
        
        strokeCollection = StrokeCollection()
    }
    
    override func tearDown() {
        super.tearDown()
        
        strokeCollection.clear()
    }
    
    func testTotalPointCount() {
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)

        XCTAssertEqual(strokeCollection.totalPointCount, 6)
        XCTAssertNotEqual(strokeCollection.totalPointCount, 0)
        XCTAssertNotEqual(strokeCollection.totalPointCount, 2)
        
        strokeCollection.removeLastStroke()
        
        XCTAssertEqual(strokeCollection.totalPointCount, 3)
        XCTAssertNotEqual(strokeCollection.totalPointCount, 6)
        XCTAssertNotEqual(strokeCollection.totalPointCount, 1)
        XCTAssertNotEqual(strokeCollection.totalPointCount, 0)
    }
    
    func testStrokeCount() {
        XCTAssertEqual(strokeCollection.strokeCount, 0)
        XCTAssertNotEqual(strokeCollection.strokeCount, 1)
        
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        XCTAssertEqual(strokeCollection.strokeCount, 1)
        XCTAssertNotEqual(strokeCollection.strokeCount, 0)
    }
    
    func testIsEmpty() {
        XCTAssertTrue(strokeCollection.isEmpty)
        
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        XCTAssertFalse(strokeCollection.isEmpty)
        
        strokeCollection.removeLastStroke()
        
        XCTAssertTrue(strokeCollection.isEmpty)
    }
    
    func testLastStroke() {
        XCTAssertNil(strokeCollection.lastStroke)
        
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        let stroke = Stroke(point: .zero, brush: blackBrush)
        stroke.points.append(.zero)
        stroke.points.append(.zero)
        
        XCTAssertNotNil(strokeCollection.lastStroke)
        XCTAssertEqual(strokeCollection.lastStroke, stroke)
    }
    
    func testLastPoint() {
        XCTAssertNil(strokeCollection.lastPoint)
        
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        XCTAssertNotNil(strokeCollection.lastPoint)
        XCTAssertEqual(strokeCollection.lastPoint, .zero)
    }
    
    func testLastBrush() {
        XCTAssertNil(strokeCollection.lastBrush)
        
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        XCTAssertNotNil(strokeCollection.lastBrush)
        XCTAssertEqual(strokeCollection.lastBrush, blackBrush)
    }
    
    func testNewStroke() {
        XCTAssertNil(strokeCollection.lastStroke)
        
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        XCTAssertNotNil(strokeCollection.lastStroke)
        XCTAssertEqual(strokeCollection.strokeCount, 1)
    }
    
    func testNewStrokeAddsThreePoints() {
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        XCTAssertNotNil(strokeCollection.lastStroke)
        XCTAssertEqual(strokeCollection.lastStroke?.points.count, 3)
    }
    
    func testNewStrokeAppendsToEnd() {
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        let secondPoint = CGPoint(x: 5, y: 5)
        strokeCollection.newStroke(initialPoint: secondPoint, brush: blackBrush)
        // Create a stroke equal to the one we just added
        let stroke = Stroke(point: secondPoint, brush: blackBrush)
        stroke.points.append(secondPoint)
        stroke.points.append(secondPoint)
        
        XCTAssertEqual(strokeCollection.lastStroke, stroke)
    }
    
    func testAddPoint() {
        XCTAssertNil(strokeCollection.lastStroke)
        XCTAssertNil(strokeCollection.lastBrush)
        XCTAssertNil(strokeCollection.lastPoint)
        XCTAssertEqual(strokeCollection.totalPointCount, 0)
        XCTAssertEqual(strokeCollection.strokeCount, 0)
        XCTAssertTrue(strokeCollection.isEmpty)
        
        strokeCollection.addPoint(.zero)
        
        XCTAssertNil(strokeCollection.lastStroke)
        XCTAssertNil(strokeCollection.lastBrush)
        XCTAssertNil(strokeCollection.lastPoint)
        XCTAssertEqual(strokeCollection.totalPointCount, 0)
        XCTAssertEqual(strokeCollection.strokeCount, 0)
        XCTAssertTrue(strokeCollection.isEmpty)
        
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        XCTAssertEqual(strokeCollection.totalPointCount, 3)
        
        let point = CGPoint(x: 10, y: 10)
        strokeCollection.addPoint(point)
        
        XCTAssertEqual(strokeCollection.totalPointCount, 4)
        XCTAssertEqual(strokeCollection.lastPoint, point)
        
        // Create a point with a distance exactly equal to 1.5 from the point we just added
        let secondPoint = CGPoint(x: 11.060660171779821, y: 11.060660171779821)
        strokeCollection.addPoint(secondPoint)
        
        XCTAssertEqual(strokeCollection.totalPointCount, 4)
        XCTAssertNotEqual(strokeCollection.lastPoint, secondPoint)
        XCTAssertEqual(strokeCollection.lastPoint, point)
    }
    
    func testRemoveLastStroke() {
        XCTAssertNil(strokeCollection.lastStroke)
        XCTAssertNil(strokeCollection.lastBrush)
        XCTAssertNil(strokeCollection.lastPoint)
        XCTAssertEqual(strokeCollection.totalPointCount, 0)
        XCTAssertEqual(strokeCollection.strokeCount, 0)
        XCTAssertTrue(strokeCollection.isEmpty)
        
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        XCTAssertNotNil(strokeCollection.lastStroke)
        XCTAssertNotNil(strokeCollection.lastBrush)
        XCTAssertNotNil(strokeCollection.lastPoint)
        XCTAssertEqual(strokeCollection.totalPointCount, 3)
        
        strokeCollection.removeLastStroke()
        
        XCTAssertNil(strokeCollection.lastStroke)
        XCTAssertNil(strokeCollection.lastBrush)
        XCTAssertNil(strokeCollection.lastPoint)
        XCTAssertEqual(strokeCollection.totalPointCount, 0)
        XCTAssertEqual(strokeCollection.strokeCount, 0)
        XCTAssertTrue(strokeCollection.isEmpty)
    }
    
    func testClear() {
        XCTAssertNil(strokeCollection.lastStroke)
        XCTAssertNil(strokeCollection.lastBrush)
        XCTAssertNil(strokeCollection.lastPoint)
        XCTAssertEqual(strokeCollection.totalPointCount, 0)
        XCTAssertEqual(strokeCollection.strokeCount, 0)
        XCTAssertTrue(strokeCollection.isEmpty)
        
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        XCTAssertNotNil(strokeCollection.lastStroke)
        XCTAssertNotNil(strokeCollection.lastBrush)
        XCTAssertNotNil(strokeCollection.lastPoint)
        XCTAssertEqual(strokeCollection.totalPointCount, 6)
        
        strokeCollection.clear()
        
        XCTAssertNil(strokeCollection.lastStroke)
        XCTAssertNil(strokeCollection.lastBrush)
        XCTAssertNil(strokeCollection.lastPoint)
        XCTAssertEqual(strokeCollection.totalPointCount, 0)
        XCTAssertEqual(strokeCollection.strokeCount, 0)
        XCTAssertTrue(strokeCollection.isEmpty)
    }
    
    func testSplitInTwoIsEmpty() {
        let emptyCollection = strokeCollection.splitInTwo(numPoints: 1000)
        
        XCTAssertNil(emptyCollection.lastStroke)
        XCTAssertNil(emptyCollection.lastBrush)
        XCTAssertNil(emptyCollection.lastPoint)
        XCTAssertEqual(emptyCollection.totalPointCount, 0)
        XCTAssertEqual(emptyCollection.strokeCount, 0)
        XCTAssertTrue(emptyCollection.isEmpty)
    }
    
    func testSplitInTwoTransfersStroke() {
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        XCTAssertEqual(strokeCollection.totalPointCount, 6)
        
        let newCollection = strokeCollection.splitInTwo(numPoints: 500)
        
        XCTAssertEqual(strokeCollection.totalPointCount, 1)
        XCTAssertEqual(newCollection.totalPointCount, 6)
    }
    
    func testSplitInTwoSplitsStroke() {
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        XCTAssertEqual(strokeCollection.totalPointCount, 3)
        
        let newCollection = strokeCollection.splitInTwo(numPoints: 2)
        
        XCTAssertEqual(strokeCollection.totalPointCount, 2)
        XCTAssertEqual(newCollection.totalPointCount, 2)
        XCTAssertEqual(strokeCollection.strokeCount, 1)
        XCTAssertEqual(newCollection.strokeCount, 1)
    }
}
