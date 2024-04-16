// Declare a class-only protocol
// that provides resilient abstraction
// (i.e. it does not leak anything about C++ dependencies)
// over the specific tab functionality
// implemented by the 'TabImplWithCustomCxxStdlib' class.
public protocol Tab: AnyObject {
    var name: String { get }

    func visit(_ url: String)
}