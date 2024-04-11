public import CoreAbstractInterface

// Import 'CoreCxxLib', which depends on custom libc++
// using implementation only import!
@_implementationOnly import CoreCxxLib

// FIXME: Drop the need for manual CxxSequence
// conformance.
import Cxx
extension stdVecInt: CxxSequence {}

// Internal class that implements the 'Program'
// protocol, that the rest of the program uses
// to interact with this Swift module.
class ProgramImplWithCustomCxxStdlib: Program {
    func getProgramName() -> String {
        return "existing in custom c++ stdlib world"
    }

    var version: Version { 
        // Call into C++ and convert the libc++ vector into
        // a Swift array.
        // test.
        let ns = getProgramVersion()
        return Version(ns.map { Int($0) })
    }

    var tabs: [any Tab] {
        return [TabImplWithCustomCxxStdlib(program: self,
        cxxTab: core.Tab(std.string("tab 1")))]
    }
}

public func createCustomProgram() -> any Program {
    return ProgramImplWithCustomCxxStdlib()
}