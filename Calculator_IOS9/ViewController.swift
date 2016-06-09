//
//  ViewController.swift
//  Calculator_IOS9
//
//  Created by jingdai yang on 5/18/16.
//  Copyright © 2016 JY. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
 
    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var history: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    @IBAction func touchDot() {
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if textCurrentlyInDisplay.rangeOfString(".") == nil {
                display.text = textCurrentlyInDisplay + "."
            }
        }else {
            display.text = "0."
            userIsInTheMiddleOfTyping = true
        }
        history.text = brain.description
    }
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        }else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
        history.text = brain.description
    }

    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        history.text = brain.description
    }
    
}

