cmake_minimum_required(VERSION 3.25)
project(swift-custom-cxx-stdlib
    LANGUAGES Swift CXX)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_Swift_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/swift)

# 'CoreAbstractInterface': base Swift library
# that declares common structures and protocols
# that don't depend on any C++ features.
add_library(CoreAbstractInterface SHARED
    Sources/CoreAbstractInterface/Program.swift
    Sources/CoreAbstractInterface/Tab.swift
    )


# Path to the custom C++ stdlib used by 'CoreCustomStdlibUser'.
set(CUSTOM_CXX_STDLIB_PATH 
    ${CMAKE_SOURCE_DIR}/deps/libcxx-x64-windows)
set(CUSTOM_CXX_STDLIB_INCLUDE_PATH
    ${CUSTOM_CXX_STDLIB_PATH}/include/c++/v1)
set(CUSTOM_CXX_STDLIB_LIB_PATH
    ${CUSTOM_CXX_STDLIB_PATH}/lib)

# Adjust the original libc++ modulemap to rename the 'std'
# module, to avoid module conflict name.
file(READ 
     ${CUSTOM_CXX_STDLIB_INCLUDE_PATH}/module.modulemap 
     LIBCXX_MODULEMAP_CONTENTS)
string(REPLACE "module std [system]" "module renamed_std [system]" LIBCXX_MODULEMAP_CONTENTS ${LIBCXX_MODULEMAP_CONTENTS})
file(WRITE ${CMAKE_BINARY_DIR}/overlay/overlay-libc++-module.modulemap ${LIBCXX_MODULEMAP_CONTENTS})
# Configure a Clang VFS overlay file to pickup the adjusted
# module map for libc++.
configure_file(overlays/overlay-custom-libc++.yaml.in
               ${CMAKE_BINARY_DIR}/overlay/overlay-custom-libc++.yaml)


# 'CoreCustomStdlibUser': This is a Swift library
# that uses 'CoreCxxLib', which in turn forces it to use
# a custom libc++ instead of system's C++ stdlib.
add_library(CoreCustomStdlibUser SHARED
    Sources/CoreCustomStdlibUser/CoreCustomStdlibProgram.swift
    Sources/CoreCustomStdlibUser/CoreCustomStdlibTab.swift
    )
target_include_directories(CoreCustomStdlibUser PRIVATE
    ${CMAKE_BINARY_DIR}/swift)
target_include_directories(CoreCustomStdlibUser PRIVATE
    ${CMAKE_SOURCE_DIR}/Sources/CoreCxxLib/include)
target_compile_options(CoreCustomStdlibUser PRIVATE
    -cxx-interoperability-mode=default)
# Find the custom C++ stdlib 'CoreCxxLib' depends on.
target_compile_options(CoreCustomStdlibUser PRIVATE
    "SHELL:$<$<COMPILE_LANGUAGE:Swift>:-Xfrontend -clang-libcxx-path${CUSTOM_CXX_STDLIB_INCLUDE_PATH}>")
# Overlay an adjusted module map for libc++, with renamed 'std' module.
target_compile_options(CoreCustomStdlibUser PRIVATE
    "SHELL:$<$<COMPILE_LANGUAGE:Swift>:-Xcc -ivfsoverlay -Xcc ${CMAKE_BINARY_DIR}/overlay/overlay-custom-libc++.yaml>")
target_link_libraries(CoreCustomStdlibUser PUBLIC
    CoreAbstractInterface)
# Make sure 'CoreCustomStdlibUser' can find libc++ to link with.
target_link_directories(CoreCustomStdlibUser PRIVATE
    ${CUSTOM_CXX_STDLIB_LIB_PATH})


# 'SampleUsesCustomStdlibModule': this is the Swift executable
# that acts as the rest of the program, that uses C++ interoperability
# with system's C++ stdlib, e.g. MSVC STL on Windows.
add_executable(SampleUsesCustomStdlibModule
    Sources/SampleUsesCustomStdlibModule/Main.swift)
target_include_directories(SampleUsesCustomStdlibModule PRIVATE
    ${CMAKE_BINARY_DIR}/swift)
target_compile_options(SampleUsesCustomStdlibModule PRIVATE
    -parse-as-library
    -cxx-interoperability-mode=default)
target_link_libraries(SampleUsesCustomStdlibModule PUBLIC
    CoreCustomStdlibUser)

# Copy over libc++ dll over to the bin directory.
add_custom_command(TARGET SampleUsesCustomStdlibModule POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${CUSTOM_CXX_STDLIB_PATH}/bin/c++.dll" 
    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}) 