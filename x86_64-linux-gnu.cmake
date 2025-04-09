# toolchain-sysroot.cmake
# CMake toolchain file for using our custom sysroot

# System information
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

# Specify the sysroot directory (adjust to your actual path)
set(SYSROOT_DIR "$ENV{HOME}/sysroot")

# Use our compilers from the sysroot
set(CMAKE_C_COMPILER clang-21)
set(CMAKE_ASM_COMPILER clang-21)
set(CMAKE_CXX_COMPILER clang++-21)

set(CMAKE_C_COMPILER_TARGET x86_64-linux-gnu)
set(CMAKE_CXX_COMPILER_TARGET x86_64-linux-gnu)
set(CMAKE_ASM_COMPILER_TARGET x86_64-linux-gnu)

# Configure search paths
set(CMAKE_SYSROOT ${SYSROOT_DIR})
set(CMAKE_FIND_ROOT_PATH ${SYSROOT_DIR})

# Use the sysroot paths with priority
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Include paths
include_directories(SYSTEM "${SYSROOT_DIR}/usr/include")

# Set appropriate flags for compiling with our sysroot
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --sysroot=${SYSROOT_DIR}  " CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --sysroot=${SYSROOT_DIR}  " CACHE STRING "" FORCE)
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --sysroot=${SYSROOT_DIR}" CACHE STRING "" FORCE)
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} --sysroot=${SYSROOT_DIR}" CACHE STRING "" FORCE)

# Make sure libraries are searched in the correct order
set(CMAKE_FIND_LIBRARY_PREFIXES "lib")
set(CMAKE_FIND_LIBRARY_SUFFIXES ".a" ".so")

# Set rpath settings
set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)