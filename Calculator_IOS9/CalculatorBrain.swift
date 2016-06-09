//
//  CalculatorBrain.swift
//  Calculator_IOS9
//
//  Created by jingdai yang on 5/19/16.
//  Copyright © 2016 JY. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    private var pending: PendingBinaryOperationInfo?
    private var history = [String]()
    private var isPartialResult = false
    
    var description: String {
        get {
            var stringList = " "
            for item in history {
                stringList += item
            }
            return stringList
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }

    func setOperand(operand: Double) {
        if pending == nil {
            history.removeAll()
        }
        accumulator = operand
        internalProgram.append(operand)
    }
    
    func updateHistory(operand: Double) {
        if isPartialResult {
            history.removeLast()
            history.append(String(operand))
        }else {
            history.append(String(operand))
        }
    }
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    private var operations = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "±" : Operation.UnaryOperation({ -$0 }),
        "√" : Operation.UnaryOperation(sqrt),    //sqrt
        "cos": Operation.UnaryOperation(cos),    //cos
        "×": Operation.BinaryOperation({ $0 * $1 }),
        "÷": Operation.BinaryOperation({ $0 / $1 }),
        "+": Operation.BinaryOperation({ $0 + $1 }),
        "−": Operation.BinaryOperation({ $0 - $1 }),
        "=": Operation.Equals,
        "C": Operation.Clear
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Clear
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let associatedConstantValue):
                accumulator = associatedConstantValue
            case .UnaryOperation(let function):
                history.removeLast()
                if pending != nil {
                    history.append(symbol)
                    history.append("(")
                    history.append(accumulator==M_PI ? "π" : String(accumulator))
                    history.append(")")
                    history.append("...")
                }else {
                    history.insert("(", atIndex: 0)
                    history.append(")")
                    history.insert(symbol,atIndex:0)
                    history.append("=")
                }
                
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                if !history.isEmpty && history[history.count-1]=="=" {
                    history.removeLast()
                }
                if history.isEmpty{
                    history.append(accumulator==M_PI ? "π" : String(accumulator))
                }
                if (symbol == "×" || symbol == "÷") && history.count>1 {
                    history.insert("(", atIndex: 0)
                    history.append(")")
                }
                history.append(symbol)
                history.append("...")
                
            case .Equals:
                executePendingBinaryOperation()
            case .Clear:
                clear()
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            history.removeLast()
            if !(history[history.count-1]==")") {
                history.append(accumulator==M_PI ? "π" : String(accumulator))
            }
            history.append("=")
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
            isPartialResult = false
        }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
        history.removeAll()
        isPartialResult = false
    }
}