cmake_minimum_required(VERSION 3.25)
project(swift-custom-cxx-stdlib
    LANGUAGES Swift CXX)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_Swift_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/swift)

# 'CommonCore': base Swift library
# that declares common structures and protocols
# that don't depend on any C++ features.
add_library(CommonCore SHARED
    Sources/CommonCore/Version.swift
    )


# Path to the custom C++ stdlib used by 'CoreLib'.
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


# 'CoreLib': This is a Swift library
# that uses 'CoreLibCxx', which in turn forces it to use
# a custom libc++ instead of system's C++ stdlib.
add_library(CoreLib SHARED
    Sources/CoreLib/Program.swift
    Sources/CoreLib/Tab.swift
    Sources/CoreLib/CoreCustomStdlibProgram.swift
    Sources/CoreLib/CoreCustomStdlibTab.swift
    Sources/CoreLib/LibcxxUtils/LibcxxString.swift
    )
target_include_directories(CoreLib PRIVATE
    ${CMAKE_BINARY_DIR}/swift)
target_include_directories(CoreLib PRIVATE
    ${CMAKE_SOURCE_DIR}/Sources/CoreLibCxx/include)
target_compile_options(CoreLib PRIVATE
    -cxx-interoperability-mode=default)
# Find the custom C++ stdlib 'CoreLibCxx' depends on.
target_compile_options(CoreLib PRIVATE
    "SHELL:$<$<COMPILE_LANGUAGE:Swift>:-Xfrontend -clang-libcxx-path${CUSTOM_CXX_STDLIB_INCLUDE_PATH}>")
# Overlay an adjusted module map for libc++, with renamed 'std' module.
target_compile_options(CoreLib PRIVATE
    "SHELL:$<$<COMPILE_LANGUAGE:Swift>:-Xcc -ivfsoverlay -Xcc ${CMAKE_BINARY_DIR}/overlay/overlay-custom-libc++.yaml>")
target_link_libraries(CoreLib PUBLIC
    CommonCore)
# Make sure 'CoreLib' can find libc++ to link with.
target_link_directories(CoreLib PRIVATE
    ${CUSTOM_CXX_STDLIB_LIB_PATH})


# 'SampleMainSwiftProgram': this is the Swift executable
# that acts as the rest of the program, that uses C++ interoperability
# with system's C++ stdlib, e.g. MSVC STL on Windows.
add_executable(SampleMainSwiftProgram
    Sources/SampleMainSwiftProgram/Main.swift)
target_include_directories(SampleMainSwiftProgram PRIVATE
    ${CMAKE_BINARY_DIR}/swift)
target_compile_options(SampleMainSwiftProgram PRIVATE
    -parse-as-library
    -cxx-interoperability-mode=default)
target_link_libraries(SampleMainSwiftProgram PUBLIC
    CoreLib)

# Copy over libc++ dll over to the bin directory.
add_custom_command(TARGET SampleMainSwiftProgram POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${CUSTOM_CXX_STDLIB_PATH}/bin/c++.dll" 
    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}) 