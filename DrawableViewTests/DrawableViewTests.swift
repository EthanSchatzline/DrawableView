//
//  DrawableViewTests.swift
//  DrawableView
//
//  Created by Ethan Schatzline on 4/19/17.
//  Copyright © 2017 Ethan Schatzline. All rights reserved.
//

import XCTest

class DrawableViewTests: XCTestCase {
    
    var drawableView: DrawableView!
    let blackBrush: Brush = Brush(width: 2.0, color: .black, transparency: 1.0)
    
    override func setUp() {
        super.setUp()
        
        drawableView = DrawableView()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // Nothing to test in DrawableView yet
}
