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
    
    @IBAction func undoOrDelete() {
        if userIsInTheMiddleOfTyping && display.text?.rangeOfString("M") == nil{
            let textCurrentlyInDisplay = display.text!
            display.text = String(textCurrentlyInDisplay.characters.dropLast())
        }else {
            var program = brain.program
            if !program.isEmpty {
                let lastOperand = program.popLast()
                if let lOp = lastOperand as? String {
                    if brain.hasVariable(lOp) {
                        brain.removeVariablesKey(lOp)
                    }
                }
            }
            brain.program = program
            displayValue = brain.result
            history.text = brain.description
        }
    }
    
    @IBAction func setM() {
        brain.setVariable("M", value: displayValue)
        let program = brain.program
        brain.program = program
        displayValue = brain.result
    }
    
    @IBAction func inputM(sender: AnyObject) {
        display.text = sender.currentTitle!
        userIsInTheMiddleOfTyping = true
        history.text = brain.description
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
        if userIsInTheMiddleOfTyping && display.text?.rangeOfString("M") == nil {
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
            if Double(display.text!) == nil {
                brain.setOperand(display.text!)
            }else {
                brain.setOperand(displayValue)
            }
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        history.text = brain.description
    }
    
}

