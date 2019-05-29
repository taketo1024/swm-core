//
//  Sequence.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/05/19.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public extension Sequence {
    func toArray() -> [Element] {
        return Array(self)
    }
    
    var anyElement: Element? {
        return first { _ in true }
    }
    
    var count: Int {
        return toArray().count
    }
    
    func count(where predicate: (Element) -> Bool) -> Int {
        return self.lazy.filter(predicate).count
    }
    
    func exclude(_ isExcluded: (Self.Element) throws -> Bool) rethrows -> [Self.Element] {
        return try self.filter{ try !isExcluded($0) }
    }
    
    func sorted<C: Comparable>(by indexer: (Element) -> C) -> [Element] {
        return self.sorted{ (e1, e2) in indexer(e1) < indexer(e2) }
    }
    
    func group<U: Hashable>(by keyGenerator: (Element) -> U) -> [U: [Element]] {
        return Dictionary(grouping: self, by: keyGenerator)
    }
    
    func allCombinations<S: Sequence>(with s2: S) -> [(Self.Element, S.Element)] {
        typealias X = Self.Element
        typealias Y = S.Element
        return self.flatMap{ (x) -> [(X, Y)] in
            s2.map{ (y) -> (X, Y) in (x, y) }
        }
    }
}

public extension Sequence where Element: Hashable {
    var isUnique: Bool {
        return self.count == unique().count
    }
    
    func unique() -> [Element] {
        var alreadyAdded = Set<Element>()
        return self.filter { alreadyAdded.insert($0).inserted }
    }
    
    func subtract(_ b: Self) -> [Element] {
        let set = Set(b)
        return self.filter{ !set.contains($0) }
    }
    
    func isDisjoint<S: Sequence>(with other: S) -> Bool where S.Element == Element {
        return Set(self).isDisjoint(with: other)
    }
    
    func countMultiplicities() -> [Element : Int] {
        return self.group{ $0 }.mapValues{ $0.count }
    }
}
