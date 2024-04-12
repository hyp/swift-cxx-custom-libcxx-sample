# Swift & C++ interoperability: Custom libc++ sample

This is a sample that demonstrates to how use
a custom libc++, to build a Swift module that depends on
some C++ headers that use the custom libc++, and how to
use such a Swift module throughout the rest of the Swift program which depends
on system's C++ stdlib, like the MSVC C++ stdlib on Windows.

This sample is geared up for x64 windows, as it includes
a distribution of libc++ for that platform, but it should
work just as well on other platforms too.

## Build & Run

```
> cmake -G Ninja -B build -S .
> ninja -C build
> build\bin\SampleUsesCustomStdlibModule.exe
```

expected output:

```
hello existing in custom c++ stdlib world!
program version (from C++ vector -> [Int]): [1, 2, 3]
tab: tab 1
will go to: swift.org
test C++ system lib
```

(More to come...)