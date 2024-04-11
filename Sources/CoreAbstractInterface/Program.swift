// Declare a common class-only protocol
// that provides abstraction over some program functionality
// implemented in 'CoreCustomStdlibUser'.

public struct Version {
    public let numbers: [Int]

    public init(_ numbers: [Int]) {
        self.numbers = numbers
    }
}

public protocol Program: AnyObject {
    func getProgramName() -> String

    var version: Version { get }

    var tabs: [any Tab] { get }
}
