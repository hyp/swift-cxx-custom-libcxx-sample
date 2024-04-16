public import CommonCore

// Declare a class-only protocol
// that provides resilient abstraction
// (i.e. it does not leak anything about C++ dependencies)
// over the specific program functionality
// implemented by the 'ProgramImplWithCustomCxxStdlib' class.
public protocol Program: AnyObject {
    func getProgramName() -> String

    var version: Version { get }

    var tabs: [any Tab] { get }
}
