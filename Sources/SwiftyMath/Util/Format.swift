//
//  Letters.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/10.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

// see: https://en.wikipedia.org/wiki/Unicode_subscripts_and_superscripts

public struct Format {
    public static func sup(_ i: Int) -> String {
        sup(String(i))
    }
    
    public static func sup(_ s: String) -> String {
        String( s.map { c in
            switch c {
            case "0": return "⁰"
            case "1": return "¹"
            case "2": return "²"
            case "3": return "³"
            case "4": return "⁴"
            case "5": return "⁵"
            case "6": return "⁶"
            case "7": return "⁷"
            case "8": return "⁸"
            case "9": return "⁹"
            case "+": return "⁺"
            case "-": return "⁻"
            case "(": return "⁽"
            case ")": return "⁾"
            case ",": return " ̓"
            default: return c
            }
        } )
    }
    
    public static func sub(_ i: Int) -> String {
        sub(String(i))
    }
    
    public static func sub(_ s: String) -> String {
        String( s.map { c in
            switch c {
            case "0": return "₀"
            case "1": return "₁"
            case "2": return "₂"
            case "3": return "₃"
            case "4": return "₄"
            case "5": return "₅"
            case "6": return "₆"
            case "7": return "₇"
            case "8": return "₈"
            case "9": return "₉"
            case "+": return "₊"
            case "-": return "₋"
            case "(": return "₍"
            case ")": return "₎"
            case ",": return " ̦"
            case "*": return " ͙"
            default: return c
            }
        } )
    }
    
    public static func symbol(_ x: String, _ i: Int) -> String {
        "\(x)\(sub(i))"
    }
    
    public static func power<X: CustomStringConvertible>(_ x: X, _ n: Int) -> String {
        let xStr = x.description
        return n == 0 ? "1" : n == 1 ? xStr : "\(xStr)\(sup(n))"
    }
    
    public static func linearCombination<S: Sequence, X: CustomStringConvertible, R: Ring>(_ terms: S) -> String where S.Element == (X, R) {
        let termsStr = terms.compactMap{ (x, r) -> String? in
            let xStr = x.description
            switch (r, xStr) {
            case (.zero, _):
                return nil
            case (_, "1"):
                return "\(r)"
            case (.identity, _):
                return xStr
            case (-.identity, _):
                return "-\(xStr)"
            default:
                return "\(r)\(xStr)"
            }
        }
        
        return termsStr.isEmpty
            ? "0"
            : termsStr.reduce(into: "") { (str, next) in
                if str.isEmpty {
                    str += next
                } else if next.hasPrefix("-") {
                    str += " - \(next.substring(1...))"
                } else {
                    str += " + \(next)"
                }
            }
    }
    
    public static func table<S1: Sequence, S2: Sequence, T>(rows: S1, cols: S2, symbol: String = "", separator s: String = "\t", printHeaders: Bool = true, op: (S1.Element, S2.Element) -> T) -> String {
        let head = printHeaders ? [[symbol] + cols.map{ y in "\(y)" }] : []
        let body = rows.enumerated().map { (i, x) -> [String] in
            let head = printHeaders ? ["\(x)"] : []
            let line = cols.enumerated().map { (j, y) in
                "\(op(x, y))"
            }
            return head + line
        }
        return (head + body).map{ $0.joined(separator: s) }.joined(separator: "\n")
    }
    
    public static func table<S: Sequence, T>(elements: S, default d: String = "", symbol: String = "j\\i", separator s: String = "\t", printHeaders: Bool = true) -> String where S.Element == (Int, Int, T) {
        let dict = Dictionary(pairs: elements.map{ (i, j, t) in ([i, j], t) } )
        if dict.isEmpty {
            return "empty"
        }
        
        let (I, J) = (dict.keys.map{$0[0]}, dict.keys.map{$0[1]})
        let (iMax, iMin) = (I.max()!, I.min()!)
        let (jMax, jMin) = (J.max()!, J.min()!)
        
        return Format.table(rows: (jMin ... jMax).reversed(),
                            cols: (iMin ... iMax),
                            symbol: symbol,
                            separator: s,
                            printHeaders: printHeaders)
        { (j, i) -> String in
            dict[ [i, j] ].map{ "\($0)" } ?? d
        }
    }
}

public extension AdditiveGroup {
    static func printAddTable(values: [Self]) {
        print( Format.table(rows: values, cols: values, symbol: "+") { $0 + $1 } )
    }
}

public extension AdditiveGroup where Self: FiniteSetType {
    static func printAddTable() {
        printAddTable(values: allElements)
    }
}

public extension Monoid {
    static func printMulTable(values: [Self]) {
        print( Format.table(rows: values, cols: values, symbol: "*") { $0 * $1 } )
    }
    
    static func printExpTable(values: [Self], upTo n: Int) {
        print( Format.table(rows: values, cols: Array(0 ... n), symbol: "^") { $0.pow($1) } )
    }
}

public extension Monoid where Self: FiniteSetType {
    static func printMulTable() {
        printMulTable(values: allElements)
    }
    
    static func printExpTable() {
        let all = allElements
        printExpTable(values: all, upTo: all.count - 1)
    }
}
