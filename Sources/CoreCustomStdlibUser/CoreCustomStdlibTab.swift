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

extension std.string {
  /// Creates a C++ string having the same content as the given Swift string.
  ///
  /// - Complexity: O(*n*), where *n* is the number of UTF-8 code units in the
  ///   Swift string.
  init(_ string: String) {
    self.init()
    for char in string.utf8 {
      self.push_back(value_type(bitPattern: char))
    }
  }
}

extension String {
  /// Creates a String having the same content as the given C++ string.
  ///
  /// If `cxxString` contains ill-formed UTF-8 code unit sequences, this
  /// initializer replaces them with the Unicode replacement character
  /// (`"\u{FFFD}"`).
  ///
  /// - Complexity: O(*n*), where *n* is the number of bytes in the C++ string.
  init(_ cxxString: std.string) {
    let buffer = UnsafeBufferPointer<CChar>(
      start: cxxString.__c_strUnsafe(),
      count: cxxString.size())
    self = buffer.withMemoryRebound(to: UInt8.self) {
      String(decoding: $0, as: UTF8.self)
    }
    withExtendedLifetime(cxxString) {}
  }
}