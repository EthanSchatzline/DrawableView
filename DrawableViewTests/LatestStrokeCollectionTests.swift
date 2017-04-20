//
//  LatestStrokeCollectionTests.swift
//  DrawableView
//
//  Created by Ethan Schatzline on 4/19/17.
//  Copyright © 2017 Ethan Schatzline. All rights reserved.
//

import XCTest

class LatestStrokeCollectionTests: XCTestCase {
    
    var latestStrokeCollection: LatestStrokeCollection!
    let blackBrush: Brush = Brush(width: 2.0, color: .black, transparency: 1.0)
    
    override func setUp() {
        super.setUp()
        
        latestStrokeCollection = LatestStrokeCollection()
    }
    
    override func tearDown() {
        super.tearDown()
        
        latestStrokeCollection.clear()
    }
    
    func testNewStroke() {
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 0)
        
        let transparentBrush = Brush(width: 4.0, color: .red, transparency: 0.5)
        latestStrokeCollection.newStroke(initialPoint: .zero, brush: transparentBrush)
        
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 0)
        
        latestStrokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 6)
        
        latestStrokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 9)
    }
    
    func testAddPoint() {
        XCTAssertNil(latestStrokeCollection.lastStroke)
        XCTAssertNil(latestStrokeCollection.lastBrush)
        XCTAssertNil(latestStrokeCollection.lastPoint)
        XCTAssertEqual(latestStrokeCollection.totalPointCount, 0)
        XCTAssertEqual(latestStrokeCollection.strokeCount, 0)
        XCTAssertTrue(latestStrokeCollection.isEmpty)
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 0)
        
        latestStrokeCollection.addPoint(.zero)
        
        XCTAssertNil(latestStrokeCollection.lastStroke)
        XCTAssertNil(latestStrokeCollection.lastBrush)
        XCTAssertNil(latestStrokeCollection.lastPoint)
        XCTAssertEqual(latestStrokeCollection.totalPointCount, 0)
        XCTAssertEqual(latestStrokeCollection.strokeCount, 0)
        XCTAssertTrue(latestStrokeCollection.isEmpty)
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 0)
        
        latestStrokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        XCTAssertEqual(latestStrokeCollection.totalPointCount, 3)
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 3)
        
        let point = CGPoint(x: 10, y: 10)
        latestStrokeCollection.addPoint(point)
        
        XCTAssertEqual(latestStrokeCollection.totalPointCount, 4)
        XCTAssertEqual(latestStrokeCollection.lastPoint, point)
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 4)
        
        // Create a point with a distance exactly equal to 1.5 from the point we just added
        let secondPoint = CGPoint(x: 11.060660171779821, y: 11.060660171779821)
        latestStrokeCollection.addPoint(secondPoint)
        
        XCTAssertEqual(latestStrokeCollection.totalPointCount, 4)
        XCTAssertNotEqual(latestStrokeCollection.lastPoint, secondPoint)
        XCTAssertEqual(latestStrokeCollection.lastPoint, point)
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 4)
    }
    
    func testRemoveLastStroke() {
        XCTAssertNil(latestStrokeCollection.lastStroke)
        XCTAssertNil(latestStrokeCollection.lastBrush)
        XCTAssertNil(latestStrokeCollection.lastPoint)
        XCTAssertEqual(latestStrokeCollection.totalPointCount, 0)
        XCTAssertEqual(latestStrokeCollection.strokeCount, 0)
        XCTAssertTrue(latestStrokeCollection.isEmpty)
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 0)
        
        latestStrokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        XCTAssertNotNil(latestStrokeCollection.lastStroke)
        XCTAssertNotNil(latestStrokeCollection.lastBrush)
        XCTAssertNotNil(latestStrokeCollection.lastPoint)
        XCTAssertEqual(latestStrokeCollection.totalPointCount, 3)
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 3)
        
        latestStrokeCollection.removeLastStroke()
        
        XCTAssertNil(latestStrokeCollection.lastStroke)
        XCTAssertNil(latestStrokeCollection.lastBrush)
        XCTAssertNil(latestStrokeCollection.lastPoint)
        XCTAssertEqual(latestStrokeCollection.totalPointCount, 0)
        XCTAssertEqual(latestStrokeCollection.strokeCount, 0)
        XCTAssertTrue(latestStrokeCollection.isEmpty)
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 0)
    }
    
    func testClear() {
        XCTAssertNil(latestStrokeCollection.lastStroke)
        XCTAssertNil(latestStrokeCollection.lastBrush)
        XCTAssertNil(latestStrokeCollection.lastPoint)
        XCTAssertEqual(latestStrokeCollection.totalPointCount, 0)
        XCTAssertEqual(latestStrokeCollection.strokeCount, 0)
        XCTAssertTrue(latestStrokeCollection.isEmpty)
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 0)
        
        latestStrokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        latestStrokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        XCTAssertNotNil(latestStrokeCollection.lastStroke)
        XCTAssertNotNil(latestStrokeCollection.lastBrush)
        XCTAssertNotNil(latestStrokeCollection.lastPoint)
        XCTAssertEqual(latestStrokeCollection.totalPointCount, 6)
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 6)
        
        latestStrokeCollection.clear()
        
        XCTAssertNil(latestStrokeCollection.lastStroke)
        XCTAssertNil(latestStrokeCollection.lastBrush)
        XCTAssertNil(latestStrokeCollection.lastPoint)
        XCTAssertEqual(latestStrokeCollection.totalPointCount, 0)
        XCTAssertEqual(latestStrokeCollection.strokeCount, 0)
        XCTAssertTrue(latestStrokeCollection.isEmpty)
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 0)
    }
    
    func testSplitInTwoIsEmpty() {
        let emptyCollection = latestStrokeCollection.splitInTwo(numPoints: 1000)
        
        XCTAssertNil(emptyCollection.lastStroke)
        XCTAssertNil(emptyCollection.lastBrush)
        XCTAssertNil(emptyCollection.lastPoint)
        XCTAssertEqual(emptyCollection.totalPointCount, 0)
        XCTAssertEqual(emptyCollection.strokeCount, 0)
        XCTAssertTrue(emptyCollection.isEmpty)
    }
    
    func testSplitInTwoTransfersStroke() {
        latestStrokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        latestStrokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        XCTAssertEqual(latestStrokeCollection.totalPointCount, 6)
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 6)
        
        let newCollection = latestStrokeCollection.splitInTwo(numPoints: 500)
        
        XCTAssertEqual(latestStrokeCollection.totalPointCount, 1)
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 1)
        XCTAssertEqual(newCollection.totalPointCount, 6)
    }
    
    func testSplitInTwoSplitsStroke() {
        latestStrokeCollection.newStroke(initialPoint: .zero, brush: blackBrush)
        
        XCTAssertEqual(latestStrokeCollection.totalPointCount, 3)
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 3)
        
        let newCollection = latestStrokeCollection.splitInTwo(numPoints: 2)
        
        XCTAssertEqual(latestStrokeCollection.transferrablePointCount, 2)
        XCTAssertEqual(latestStrokeCollection.totalPointCount, 2)
        XCTAssertEqual(newCollection.totalPointCount, 2)
        XCTAssertEqual(latestStrokeCollection.strokeCount, 1)
        XCTAssertEqual(newCollection.strokeCount, 1)
    }
}
