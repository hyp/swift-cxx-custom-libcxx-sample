public import CoreAbstractInterface

// Import 'CoreCxxLib', which depends on custom libc++
// using implementation only import!
@_implementationOnly import CoreCxxLib

class TabImplWithCustomCxxStdlib: Tab {
    let program: ProgramImplWithCustomCxxStdlib
    var cxxTab: core.Tab

    init(program: ProgramImplWithCustomCxxStdlib,
        cxxTab: core.Tab) {
        self.program = program
        self.cxxTab = cxxTab
    }

    var name: String { 
        // Convert the C++ std.string to Swift string.
        String(cxxTab.getName())
    }

    func visit(_ url: String) {
        // Convert the Swift string to C++ std.string.
        cxxTab.visitPage(std.string(url))
    }
}
