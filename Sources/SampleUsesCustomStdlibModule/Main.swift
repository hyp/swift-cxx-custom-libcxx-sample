import CoreCustomStdlibUser
import CxxStdlib

@main
struct Mainer {
    public static func main() {
        let s = createCustomProgram()
        print("hello \(s.getProgramName())!")
        print("program version (from C++ vector -> [Int]): \(s.version.numbers)")

        let tabs = s.tabs
        for t in tabs {
            print("tab: \(t.name)")
            t.visit("swift.org")
        }

        // Make sure we can use system C++ stdlib.
        let useSystemStdString = std.string("test C++ system lib")
        print(String(useSystemStdString))
    }
}

