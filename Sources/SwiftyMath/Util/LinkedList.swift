//
//  LinkedList.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/06/25.
//

public final class LinkedList<T>: Sequence, CustomStringConvertible {
    public var value: T
    public var next: LinkedList<T>?
    
    public init(_ value: T, next: LinkedList<T>? = nil) {
        self.value = value
        self.next = next
    }
    
    public static func generate<S: Sequence>(from seq: S) -> LinkedList<T>? where S.Element == T {
        seq.reduce(into: (nil, nil)) {
            (res: inout (head: LinkedList<T>?, prev: LinkedList<T>?), value: T) in
            
            let curr = LinkedList(value)
            if res.head == nil {
                res.head = curr
            }
            res.prev?.next = curr
            res.prev = curr
        }.head
    }
    
    public func insert(_ c: LinkedList<T>) {
        let next = self.next
        self.next = c
        c.next = next
    }
    
    public func drop(where shouldDrop: (T) -> Bool) -> LinkedList<T>? {
        var head = self
        while shouldDrop(head.value) {
            if let next = head.next {
                head = next
            } else {
                return nil
            }
        }
        
        var current = head
        while let next = current.next {
            if shouldDrop(next.value) {
                current.next = next.next
            } else {
                current = next
            }
        }
        
        return head
    }
    
    public func makeIterator() -> Iterator {
        Iterator(self)
    }
    
    public struct Iterator: IteratorProtocol {
        private var current: LinkedList<T>?
        fileprivate init(_ start: LinkedList<T>) {
            current = start
        }
        
        public mutating func next() -> T? {
            defer {
                current = current?.next
            }
            return current?.value
        }
    }
    
    public var description: String {
        "[\(value) \(next == nil ? "(end)" : "->")]"
    }
}

