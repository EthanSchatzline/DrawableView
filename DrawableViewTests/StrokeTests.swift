//
//  StrokeTests.swift
//  DrawableView
//
//  Created by Ethan Schatzline on 4/19/17.
//  Copyright © 2017 Ethan Schatzline. All rights reserved.
//

import XCTest

class StrokeTests: XCTestCase {
    
    let blackBrush: Brush = Brush(width: 2.0, color: .black, transparency: 1.0)
    var stroke: Stroke!
    
    override func setUp() {
        super.setUp()
        
        stroke = Stroke(point: .zero, brush: blackBrush)
        stroke.points.append(.zero)
        stroke.points.append(.zero)
    }
    
    override func tearDown() {
        super.tearDown()
        
        stroke.points.removeAll()
    }
    
    func testSmoothPoints() {
        stroke.points.append(CGPoint(x: 10, y: 10))
        stroke.points.append(CGPoint(x: 0, y: 20))
        // Expected points for stroke.smoothPoints
        // Interpolated points minus the last 2 points ^
        let expectedPoints = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0.55555555555555558, y: 0.55555555555555558),
            CGPoint(x: 2.2222222222222223, y: 2.2222222222222223),
            CGPoint(x: 5, y: 5),
            CGPoint(x: 5, y: 5),
            CGPoint(x: 7.2222222222222232, y: 8.3333333333333339),
            CGPoint(x: 7.2222222222222223, y: 11.666666666666666),
            CGPoint(x: 5, y: 15)
        ]
        XCTAssertEqual(stroke.smoothPoints, expectedPoints)
    }
}
