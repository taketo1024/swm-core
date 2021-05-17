//
//  MatrixInterafce.swift
//
//
//  Created by Taketo Sano.
//

public struct MatrixInterface<Impl: MatrixImpl, n: SizeType, m: SizeType>: SetType {
    public typealias BaseRing = Impl.BaseRing
    public typealias Initializer = Impl.Initializer
    
    public var impl: Impl
    
    public init(_ impl: Impl) {
        assert(n.isDynamic || n.intValue == impl.size.rows)
        assert(m.isDynamic || m.intValue == impl.size.cols)
        self.impl = impl
    }
    
    public init(size: (Int, Int), initializer: ( (Int, Int, BaseRing) -> Void ) -> Void) {
        self.init(Impl(size: size, initializer: initializer))
    }

    public init<S: Sequence>(size: (Int, Int), grid: S) where S.Element == BaseRing {
        self.init(Impl(size: size, grid: grid))
    }
    
    public init<OtherImpl>(_ other: MatrixInterface<OtherImpl, n, m>) where OtherImpl.BaseRing == BaseRing {
        self.init(Impl.init(size: other.size, grid: other.serialize()))
    }
    
    public static func zero(size: (Int, Int)) -> Self {
        self.init(Impl.zero(size: size))
    }
    
    public static func identity(size: (Int, Int)) -> Self {
        self.init(Impl.identity(size: size))
    }
    
    public static func unit(size: (Int, Int), at: (Int, Int)) -> Self {
        self.init(Impl.unit(size: size, at: at))
    }
    
    public subscript(i: Int, j: Int) -> BaseRing {
        get {
            impl[i, j]
        } set {
            impl[i, j] = newValue
        }
    }
    
    public var size: (rows: Int, cols: Int) {
        impl.size
    }
    
    public var isZero: Bool {
        impl.isZero
    }
    
    public var isSquare: Bool {
        impl.isSquare
    }
    
    public var transposed: MatrixInterface<Impl, m, n> {
        .init(impl.transposed)
    }
    
    public func rowVector(_ i: Int) -> MatrixInterface<Impl, _1, m> {
        submatrix(rowRange: i ..< i + 1, colRange: 0 ..< size.cols)
            .as(MatrixInterface<Impl, _1, m>.self)
    }
    
    public func colVector(_ j: Int) -> MatrixInterface<Impl, n, _1> {
        submatrix(rowRange: 0 ..< size.rows, colRange: j ..< j + 1)
            .as(MatrixInterface<Impl, n, _1>.self)
    }
    
    public func submatrix(rowRange: CountableRange<Int>) -> MatrixInterface<Impl, DynamicSize, m> {
        submatrix(rowRange: rowRange, colRange: 0 ..< size.cols)
            .as(MatrixInterface<Impl, DynamicSize, m>.self)
    }
    
    public func submatrix(colRange: CountableRange<Int>) -> MatrixInterface<Impl, n, DynamicSize> {
        submatrix(rowRange: 0 ..< size.rows, colRange: colRange)
            .as(MatrixInterface<Impl, n, DynamicSize>.self)
    }
    
    public func submatrix(rowRange: CountableRange<Int>,  colRange: CountableRange<Int>) -> MatrixInterface<Impl, DynamicSize, DynamicSize> {
        .init(impl.submatrix(rowRange: rowRange, colRange: colRange))
    }
    
    public func concat<m1>(_ B: MatrixInterface<Impl, n, m1>) -> MatrixInterface<Impl, n, DynamicSize> {
        .init(impl.concat(B.impl))
    }
    
    public func stack<n1>(_ B: MatrixInterface<Impl, n1, m>) -> MatrixInterface<Impl, DynamicSize, m> {
        .init(impl.stack(B.impl))
    }
    
    public func permuteRows(by σ: Permutation<n>) -> Self {
        .init(impl.permuteRows(by: σ.asDynamic))
    }
    
    public func permuteCols(by σ: Permutation<m>) -> Self {
        .init(impl.permuteCols(by: σ.asDynamic))
    }
    
    public func serialize() -> [BaseRing] {
        impl.serialize()
    }
    
    public static func ==(a: Self, b: Self) -> Bool {
        a.impl == b.impl
    }
    
    public static func +(a: Self, b: Self) -> Self {
        .init(a.impl + b.impl)
    }
    
    public prefix static func -(a: Self) -> Self {
        .init(-a.impl)
    }
    
    public static func -(a: Self, b: Self) -> Self {
        .init(a.impl - b.impl)
    }
    
    public static func *(r: BaseRing, a: Self) -> Self {
        .init(r * a.impl)
    }
    
    public static func *(a: Self, r: BaseRing) -> Self {
        .init(a.impl * r)
    }
    
    public static func * <p>(a: MatrixInterface<Impl, n, m>, b: MatrixInterface<Impl, m, p>) -> MatrixInterface<Impl, n, p> {
        .init(a.impl * b.impl)
    }
    
    public static func ⊕ <n1, m1>(A: MatrixInterface<Impl, n, m>, B: MatrixInterface<Impl, n1, m1>) -> MatrixInterface<Impl, DynamicSize, DynamicSize> {
        .init(A.impl ⊕ B.impl)
    }
    
    public static func ⊗ <n1, m1>(A: MatrixInterface<Impl, n, m>, B: MatrixInterface<Impl, n1, m1>) -> MatrixInterface<Impl, DynamicSize, DynamicSize> {
        .init(A.impl ⊗ B.impl)
    }
    
    public static func *(σ: Permutation<n>, a: Self) -> Self {
        a.permuteRows(by: σ)
    }
    
    public static func *(a: Self, σ: Permutation<m>) -> Self {
        a.permuteCols(by: σ)
    }
    
    public func `as`<n1, m1>(_ type: MatrixInterface<Impl, n1, m1>.Type) -> MatrixInterface<Impl, n1, m1> {
        MatrixInterface<Impl, n1, m1>(impl)
    }
    
    public var asDynamicMatrix: MatrixInterface<Impl, DynamicSize, DynamicSize> {
        self.as(MatrixInterface<Impl, DynamicSize, DynamicSize>.self)
    }
    
    public var description: String {
        impl.description
    }
    
    public var detailDescription: String {
        impl.detailDescription
    }
    
    public static var symbol: String {
        func str(_ t: SizeType.Type) -> String {
            !t.isDynamic ? "\(t.intValue)" : "d"
        }
        if !m.isDynamic && m.intValue == 1 {
            return "ColVec<\(str(n.self)); \(BaseRing.symbol)>"
        }
        if !n.isDynamic && n.intValue == 1 {
            return "RowVec<\(str(n.self)); \(BaseRing.symbol)>"
        }
        return "Mat<\(str(n.self)), \(str(n.self)); \(BaseRing.symbol)>"
    }
}

extension MatrixInterface where Impl: SparseMatrixImpl {
    public var numberOfNonZeros: Int {
        impl.numberOfNonZeros
    }
    
    public var nonZeroComponents: AnySequence<MatrixComponent<BaseRing>> {
        impl.nonZeroComponents
    }
}

extension MatrixInterface where n == m { // n, m: possibly dynamic
    public var isInvertible: Bool {
        isSquare && impl.isInvertible
    }
    
    public var inverse: Self? {
        isSquare ? impl.inverse.flatMap{ .init($0) } : nil
    }
    
    public var determinant: BaseRing {
        impl.determinant
    }

    public var trace: BaseRing {
        impl.trace
    }
}

// ColVector
extension MatrixInterface where m == _1 { // n: possibly dynamic
    public init(size n: Int, initializer s: @escaping ((Int, BaseRing) -> Void) -> Void) {
        self.init(Impl(size: (n, 1)) { setEntry in
            s { (i, a) in
                setEntry(i, 0, a)
            }
        })
    }
    
    public init(size n: Int, grid: [BaseRing]) {
        self.init(Impl.init(size: (n, 1), grid: grid))
    }
    
    public static func zero(size n: Int) -> Self {
        self.init(Impl.zero(size: (n, 1)))
    }
    
    public static func unit(size n: Int, at i: Int) -> Self {
        self.init(Impl.unit(size: (n, 1), at: (i, 0)))
    }

    public subscript(index: Int) -> BaseRing {
        get {
            self[index, 0]
        } set {
            self[index, 0] = newValue
        }
    }
    
    public static func •(_ left: Self, _ right: Self) -> BaseRing {
        assert(left.size == right.size)
        return (0 ..< left.size.rows).sum { i in left[i] * right[i] }
    }
}

// RowVector
extension MatrixInterface where n == _1 { // m: possibly dynamic
    public init(size m: Int, initializer s: @escaping ((Int, BaseRing) -> Void) -> Void) {
        self.init(Impl(size: (1, m)) { setEntry in
            s { (j, a) in
                setEntry(0, j, a)
            }
        })
    }
    
    public init(size m: Int, grid: [BaseRing]) {
        self.init(Impl.init(size: (1, m), grid: grid))
    }
    
    public static func zero(size m: Int) -> Self {
        self.init(Impl.zero(size: (1, m)))
    }
    
    public static func unit(size m: Int, at j: Int) -> Self {
        self.init(Impl.unit(size: (1, m), at: (0, j)))
    }
    
    public subscript(index: Int) -> BaseRing {
        get {
            self[0, index]
        } set {
            self[0, index] = newValue
        }
    }
    
    public static func •(_ left: Self, _ right: Self) -> BaseRing {
        assert(left.size == right.size)
        return (0 ..< left.size.rows).sum { i in left[i] * right[i] }
    }
}