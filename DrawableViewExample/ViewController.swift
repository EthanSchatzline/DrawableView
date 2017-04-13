//
//  ViewController.swift
//  DrawableViewExample
//
//  Created by Ethan Schatzline on 4/9/17.
//  Copyright © 2017 Ethan Schatzline. All rights reserved.
//

import UIKit
import DrawableView

private enum Color {
    case red, green, blue, purple, black
    
    var value: UIColor {
        switch self {
        case .red:
            return .red
        case .green:
            return .green
        case .blue:
            return .blue
        case .purple:
            return .purple
        case .black:
            return .black
        }
    }
}

private enum Width {
    case small, medium, large
    
    var value: CGFloat {
        switch self {
        case .small:
            return 4.0
        case .medium:
            return 12.0
        case .large:
            return 24.0
        }
    }
}

class ViewController: UIViewController, DrawableViewDelegate {

    @IBOutlet var drawableView: DrawableView! {
        didSet {
            drawableView.delegate = self
        }
    }
    
    @IBOutlet var redButton: UIButton!
    @IBOutlet var greenButton: UIButton!
    @IBOutlet var blueButton: UIButton!
    @IBOutlet var purpleButton: UIButton!
    @IBOutlet var blackButton: UIButton!
    
    @IBOutlet var smallButton: UIButton!
    @IBOutlet var mediumButton: UIButton!
    @IBOutlet var largeButton: UIButton!
    
    @IBOutlet var drawingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setColor(.red)
        setWidth(.small)
    }
    
    func setDrawing(_ isDrawing: Bool) {
        drawingLabel.text = isDrawing ? "Drawing" : "Not Drawing"
        drawingLabel.backgroundColor = isDrawing ? .green : .red
    }
    
    private func color(for bool: Bool) -> UIColor {
        return bool ? .lightGray : .clear
    }
    
    fileprivate func setColor(_ color: Color) {
        drawableView.strokeColor = color.value
        redButton.backgroundColor = self.color(for: (color == .red))
        greenButton.backgroundColor = self.color(for: (color == .green))
        blueButton.backgroundColor = self.color(for: (color == .blue))
        purpleButton.backgroundColor = self.color(for: (color == .purple))
        blackButton.backgroundColor = self.color(for: (color == .black))
    }
    
    fileprivate func setWidth(_ width: Width) {
        drawableView.strokeWidth = width.value
        smallButton.backgroundColor = self.color(for: (width == .small))
        mediumButton.backgroundColor = self.color(for: (width == .medium))
        largeButton.backgroundColor = self.color(for: (width == .large))
    }
}

extension ViewController {
    @IBAction func transparencySwitchDidChange(_ sender: UISwitch) {
        drawableView.strokeTransparency = sender.isOn ? 0.5 : 1.0
    }
    
    @IBAction func undoButtonTapped(_ sender: Any) {
        drawableView.undo()
    }
}

extension ViewController {
    @IBAction func smallButtonTapped(_ sender: Any) {
        setWidth(.small)
    }
    
    @IBAction func mediumButtonTapped(_ sender: Any) {
        setWidth(.medium)
    }
    
    @IBAction func largeButtonTapped(_ sender: Any) {
        setWidth(.large)
    }
}

extension ViewController {
    @IBAction func redButtonTapped(_ sender: Any) {
        setColor(.red)
    }
    
    @IBAction func greenButtonTapped(_ sender: Any) {
        setColor(.green)
    }
    
    @IBAction func blueButtonTapped(_ sender: Any) {
        setColor(.blue)
    }
    
    @IBAction func purpleButtonTapped(_ sender: Any) {
        setColor(.purple)
    }
    
    @IBAction func blackButtonTapped(_ sender: Any) {
        setColor(.black)
    }
}
