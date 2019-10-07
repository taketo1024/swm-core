//
//  MatrixImpl.swift
//  Sample
//
//  Created by Taketo Sano on 2019/10/04.
//

public protocol MatrixImpl {
    associatedtype BaseRing: Ring
    
    init(size: (Int, Int), initializer: ( (Int, Int, R) -> Void ) -> Void)
    
    subscript(i: Int, j: Int) -> R { get set }
    var size: (rows: Int, cols: Int) { get }
    
    var diagonalComponents: [R] { get }
    var nonZeroComponents: AnySequence<MatrixComponent<BaseRing>> { get }
    
    var transposed: Self { get }
    
    var determinant: BaseRing { get }
    var isInvertible: Bool { get }
    var inverse: Self? { get }
    
    static func ==(a: Self, b: Self) -> Bool
    static func +(a: Self, b: Self) -> Self
    static func *(a: Self, b: Self) -> Self
}

extension MatrixImpl {
    public typealias R = BaseRing
    
}

public struct DefaultMatrixImpl<R: Ring>: MatrixImpl {
    public typealias BaseRing = R
    private typealias Data = [Coord : R]
    
    public var size: (rows: Int, cols: Int)
    private var data: Data
    
    private init(size: (Int, Int), data: Data) {
        assert(!data.contains{ $0.value.isZero })
        self.size = size
        self.data = data
    }
    
    public init(size: (Int, Int), initializer: ( (Int, Int, R) -> Void ) -> Void) {
        var data: Data = [:]
        initializer { (i, j, a) in
            assert( 0 <= i && i < size.0 )
            assert( 0 <= j && j < size.1 )
            if !a.isZero {
                data[Coord(i, j)] = a
            }
        }
        self.init(size: size, data: data)
    }

    public subscript(i: Int, j: Int) -> R {
        get {
            data[i, j] ?? .zero
        } set {
            data[i, j] = (newValue.isZero) ? nil : newValue
        }
    }
    
    public var diagonalComponents: [R] {
        let r = Swift.min(size.rows, size.cols)
        return (0 ..< r).map{ i in self[i, i] }
    }
    
    public var nonZeroComponents: AnySequence<(row: Int, col: Int, value: R)> {
        AnySequence( data.lazy.map{ (c, a) -> MatrixComponent<R> in (c.row, c.col, a) } )
    }
    
    public var transposed: Self {
        .init(size: (size.cols, size.rows), data: data.mapKeys{ c in Coord(c.col, c.row) } )
    }
    
    fileprivate var isSquare: Bool {
        size.rows == size.cols
    }
    
    public var determinant: R {
        assert(isSquare)
        if size.rows == 0 {
            return .identity
        } else {
            return nonZeroComponents
                .filter{ (i, j, a) in i == 0 }
                .sum { (_, j, a) in a * cofactor(0, j) }
        }
    }

    public var isInvertible: Bool {
        determinant.isInvertible
    }

    public var inverse: Self? {
        assert(isSquare)
        if let dInv = determinant.inverse {
            return .init(size: size) { setEntry in
                ((0 ..< size.rows) * (0 ..< size.cols)).forEach { (i, j) in
                    let a = dInv * cofactor(j, i)
                    setEntry(i, j, a)
                }
            }
        } else {
            return nil
        }
    }
    
    public static func ==(a: Self, b: Self) -> Bool {
        a.data == b.data
    }
    
    public static func +(a: Self, b: Self) -> Self {
        assert(a.size == b.size)
        return .init(size: a.size, data: a.data.merging(b.data, uniquingKeysWith: +).exclude{ $0.value.isZero })
    }
    
    public static func *(a: Self, b: Self) -> Self {
        assert(a.size.cols == b.size.rows)
        
        let aRows = a.data.group{ (c, _) in c.row }
        let bRows = b.data.group{ (c, _) in c.row }
        var cData: Data = [:]
        
        //       j              k
        //                    |          |
        //  i>|  a    *  |  j>| b   *    |
        //                    |          |
        //                    | *      * |
        //                    |          |
        //
        //                         ↓
        //                      k
        //                  i>| *   *  * |
        
        for (i, Ai) in aRows {
            for (c1, a_ij) in Ai {
                let j = c1.col
                guard let Bj = bRows[j] else {
                    continue
                }
                for (c2, b_jk) in Bj {
                    let k = c2.col
                    let c3 = Coord(i, k)
                    cData[c3] = (cData[c3] ?? .zero) + a_ij * b_jk
                }
            }
        }
        
        return .init(size: (a.size.rows, b.size.cols), data: cData.exclude{ $0.value.isZero })
    }
    
    private func cofactor(_ i: Int, _ j: Int) -> R {
        assert(isSquare)

        let ε = (-R.identity).pow(i + j)
        let subdata = self.data
            .exclude { (c, _) in c.row == i || c.col == j }
            .mapKeys { c -> Coord in
                let (i1, j1) = c.tuple
                return Coord(
                    i1 < i ? i1 : i1 - 1,
                    j1 < j ? j1 : j1 - 1
                )
            }
        let A = Self(size: (size.rows - 1, size.cols - 1), data: subdata)
        return ε * A.determinant
    }
}

fileprivate struct Coord: Hashable {
    let row, col: Int
    init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }
    var tuple: (Int, Int) {
        (row, col)
    }
}

fileprivate extension Dictionary where Key == Coord {
    subscript(_ i: Int, _ j: Int) -> Value? {
        get {
            self[Coord(i, j)]
        } set {
            self[Coord(i, j)] = newValue
        }
    }
}
