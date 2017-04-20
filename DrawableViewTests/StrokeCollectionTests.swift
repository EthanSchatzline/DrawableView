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
        testIsEmptyStrokeCollection()
    }
    
    override func tearDown() {
        super.tearDown()
        
        strokeCollection.clear()
    }
    
    func testIsEmptyStrokeCollection() {
        XCTAssertNil(strokeCollection.lastStroke)
        XCTAssertNil(strokeCollection.lastBrush)
        XCTAssertNil(strokeCollection.lastPoint)
        XCTAssertEqual(strokeCollection.totalPointCount, 0)
        XCTAssertEqual(strokeCollection.strokeCount, 0)
        XCTAssertTrue(strokeCollection.isEmpty)
    }
    
    func testTotalPointCount() {
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        strokeCollection.removeLastStroke()
        XCTAssertEqual(strokeCollection.totalPointCount, 3)
    }
    
    func testStrokeCount() {
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        XCTAssertEqual(strokeCollection.strokeCount, 1)
    }
    
    func testIsEmpty() {
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        XCTAssertFalse(strokeCollection.isEmpty)
        strokeCollection.removeLastStroke()
        XCTAssertTrue(strokeCollection.isEmpty)
    }
    
    func testLastStroke() {
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        let stroke = Stroke(point: .zero, brush: blackBrush)
        stroke.points.append(.zero)
        stroke.points.append(.zero)
        XCTAssertEqual(strokeCollection.lastStroke, stroke)
    }
    
    func testLastPoint() {
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        XCTAssertEqual(strokeCollection.lastPoint, .zero)
    }
    
    func testLastBrush() {
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        XCTAssertEqual(strokeCollection.lastBrush, blackBrush)
    }
    
    func testNewStroke() {
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        XCTAssertEqual(strokeCollection.strokeCount, 1)
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
    
    func testAddPointToEmptyCollection() {
        strokeCollection.addPoint(.zero)
        testIsEmptyStrokeCollection()
    }
    
    func testAddInvalidPoint() {
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        let point = CGPoint(x: 1.060660171779821, y: 1.060660171779821)
        strokeCollection.addPoint(point)
        XCTAssertEqual(strokeCollection.totalPointCount, 3)
    }
    
    func testAddPoint() {
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        let point = CGPoint(x: 10, y: 10)
        strokeCollection.addPoint(point)
        XCTAssertEqual(strokeCollection.totalPointCount, 4)
    }
    
    func testRemoveLastStroke() {
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        strokeCollection.removeLastStroke()
        testIsEmptyStrokeCollection()
    }
    
    func testClear() {
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        strokeCollection.clear()
        testIsEmptyStrokeCollection()
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
        let newCollection = strokeCollection.splitInTwo(numPoints: 500)
        XCTAssertEqual(strokeCollection.totalPointCount, 1)
        XCTAssertEqual(newCollection.totalPointCount, 6)
    }
    
    func testSplitInTwoSplitsStroke() {
        strokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        let newCollection = strokeCollection.splitInTwo(numPoints: 2)
        XCTAssertEqual(strokeCollection.totalPointCount, 2)
        XCTAssertEqual(newCollection.totalPointCount, 2)
        XCTAssertEqual(strokeCollection.strokeCount, 1)
        XCTAssertEqual(newCollection.strokeCount, 1)
    }
}
