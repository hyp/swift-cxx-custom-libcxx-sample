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
> build\bin\SampleMainSwiftProgram.exe
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


1) 'CommonCore': A core Swift library with some common
   data types used by all targets, like the `Version`
   struct. This library doesn't use C++
   interoperability, and thus it can be used by other 
   Swift libraries, that either use custom libc++, or system's C++ stdlib.

2) 'CoreLibCxx' : This is the C++ library that depends on
   using the custom libc++. It's header only for the purpose
   of simplifying this sample.

3) 'CoreLib': This is the Swift library that
   uses custom libc++ and imports 'CoreLibCxx', to provide
   a Swift wrapper that operates on 'CoreLibCxx'.
   It uses two public class protocols 'Tab' and
   'Program' to provide a resilient abstraction
   over the implementation of the 'Program' and 'Tab'
   functionality in this library. Such abstraction 
   ensures that C++ dependency details from 'CoreLibCxx' do
   not leak to other Swift dependencies, like 'SampleMainSwiftProgram'.
   These two protocols are implemented using two
   private classes that operate on the APIs provided
   by the 'CoreLibCxx' C++ library.

4) 'SampleMainSwiftProgram': This is the Swift 
   executable that acts as the rest of the program,
   and uses system's C++ stdlib. It interacts with
   'CoreLib' using some Swift-only function
   and protocol-based
   APIs from 'CoreLib'.
