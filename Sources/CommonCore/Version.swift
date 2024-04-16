// Declare a common struct
// that is used by both 'CoreCustomStdlibUser'
// and 'SampleUsesCustomStdlibModule'.
public struct Version {
    public let numbers: [Int]

    public init(_ numbers: [Int]) {
        self.numbers = numbers
    }
}
