// Declare a common class-only protocol
// that provides abstraction over some tab functionality
// implemented in 'CoreCustomStdlibUser'.

public protocol Tab: AnyObject {
    var name: String { get }

    func visit(_ url: String)
}