//
//  FileArray+Helpers.swift
//  DrawableView
//
//  Created by Ethan Schatzline on 4/16/17.
//  Copyright © 2017 Ethan Schatzline. All rights reserved.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
