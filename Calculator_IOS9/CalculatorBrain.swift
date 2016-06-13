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
    private var accumulator: AnyObject?
    private var internalProgram = [AnyObject]()
    private var pending: PendingBinaryOperationInfo?
    private var history = [String]()
    private var isPartialResult = false
    private var variableValues: Dictionary<String, Double> = [:]
    
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
            if let rs = accumulator as? Double {
                return rs
            }else {
                return 0.0
            }
        }
    }
    
    func getVariable(variable: String) -> Double {
        if variableValues.keys.contains(variable) {
            return variableValues[variable]!
        }else {
            return 0.0
        }
    }
    
    func setVariable(variable: String, value: Double) {
        variableValues.updateValue(value, forKey: variable)
    }
    
    func removeVariablesKey(variable: String) {
        variableValues.removeValueForKey(variable)
    }
    
    func hasVariable(variable: String) -> Bool{
        return variableValues.keys.contains(variable)
    }

    func setOperand(operand: AnyObject) {
        if pending == nil {
            history.removeAll()
        }
        accumulator = operand
        internalProgram.append(operand)
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
                    if let ac = accumulator as? String {
                        history.append(ac)
                    }else if let ac = accumulator as? Double {
                        history.append(ac==M_PI ? "π" : String(ac))
                    }
                    history.append(")")
                    history.append("...")
                }else {
                    history.insert("(", atIndex: 0)
                    history.append(")")
                    history.insert(symbol,atIndex:0)
                    history.append("=")
                }
                if let ac = accumulator as? String {
                    accumulator = function(getVariable(ac))
                }else if let ac = accumulator as? Double {
                    accumulator = function(ac)
                }
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                var tmpAcc = 0.0
                if let ac = accumulator as? String {
                    tmpAcc = getVariable(ac)
                }else if let ac = accumulator as? Double {
                    tmpAcc = ac
                }
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: tmpAcc)
                if !history.isEmpty && history[history.count-1]=="=" {
                    history.removeLast()
                }
                if history.isEmpty{
                    if let ac = accumulator as? String {
                        history.append(ac)
                    }else if let ac = accumulator as? Double {
                        history.append(ac==M_PI ? "π" : String(ac))
                    }
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
                if let ac = accumulator as? String {
                    history.append(ac)
                }else if let ac = accumulator as? Double {
                    history.append(ac==M_PI ? "π" : String(ac))
                }
            }
            history.append("=")
            var tmpAcc = 0.0
            if let ac = accumulator as? String {
                tmpAcc = getVariable(ac)
            }else if let ac = accumulator as? Double {
                tmpAcc = ac
            }
            accumulator = pending!.binaryFunction(pending!.firstOperand, tmpAcc)
            pending = nil
            isPartialResult = false
        }
    }
    
    typealias PropertyList = AnyObject
    
    var program: [PropertyList] {
        get {
            return internalProgram
        }
        set {
            clearInternalProgram()
//            if let arrayOfOps = newValue as! [AnyObject] {
                for op in newValue {
                    print("\(op)")
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        if variableValues.keys.contains(operation) {
                            setOperand(variableValues[operation]!)
                        }else if operations.keys.contains(operation){
                            performOperation(operation)
                        }else {
                            setOperand(operation)
                        }
                    }
//                }
            }
        }
    }
    
    func clear() {
        variableValues.removeAll()
        clearInternalProgram()
    }
    
    func clearInternalProgram() {
        accumulator = 0.0
        pending = nil
        history.removeAll()
        isPartialResult = false
        internalProgram.removeAll()
    }
}