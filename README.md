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

## Project structure

This project is broken down into the following subtargets:

1) 'CoreCxxLib' : This is the C++ library that depends on
   using the custom libc++. It's header only for the purpose
   of simplifying this sample.

2) 'CoreAbstractInterface': This is the Swift library that
   defines Swift structures and AnyObject protocols that
   are then implemented and used to interact between
   'CoreCustomStdlibUser' and 'SampleUsesCustomStdlibModule'.
   It doesn't use C++
   interoperability, so that it can be used by other 
   Swift libraries, that either use custom libc++, or system's C++ stdlib.

3) 'CoreCustomStdlibUser': This is the Swift library that
   uses custom libc++ and imports CoreCxxLib, to provide
   a Swift wrapper that operates on CoreCxxLib. It
   implements the protocols declared in 'CoreAbstractInterface',
   which are then used by 'SampleUsesCustomStdlibModule'
   through the abstraction provided by the protocol.

4) 'SampleUsesCustomStdlibModule': This is the Swift 
   executable that acts as the rest of the program,
   and uses system's C++ stdlib. It interacts with
   'CoreCustomStdlibUser' using some Swift-only
   APIs from 'CoreCustomStdlibUser', and also using
   protocols and structures declared in 'CoreAbstractInterface'.
