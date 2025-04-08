# CMake toolchain file for x86_64-linux-llvm cross compilation
# Save as x86_64-linux-llvm.cmake

# System information
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

# Target triplet
set(TARGET_TRIPLET "x86_64-unknown-linux-llvm")

# Paths
set(SYSROOT_DIR "$ENV{HOME}/sysroot" CACHE PATH "Path to the sysroot")

# Don't look for programs/libraries/includes in the host directories
set(CMAKE_FIND_ROOT_PATH "${SYSROOT_DIR}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Compilers and tools
set(CMAKE_C_COMPILER "${SYSROOT_DIR}/bin/clang")
set(CMAKE_CXX_COMPILER "${SYSROOT_DIR}/bin/clang++")
set(CMAKE_AR "${SYSROOT_DIR}/bin/llvm-ar")
set(CMAKE_RANLIB "${SYSROOT_DIR}/bin/llvm-ranlib")
set(CMAKE_STRIP "${SYSROOT_DIR}/bin/llvm-strip")
set(CMAKE_NM "${SYSROOT_DIR}/bin/llvm-nm")
set(CMAKE_OBJCOPY "${SYSROOT_DIR}/bin/llvm-objcopy")
set(CMAKE_OBJDUMP "${SYSROOT_DIR}/bin/llvm-objdump")
set(CMAKE_LINKER "${SYSROOT_DIR}/bin/lld")

# Add the target triplet to the compiler
set(CMAKE_C_COMPILER_TARGET ${TARGET_TRIPLET})
set(CMAKE_CXX_COMPILER_TARGET ${TARGET_TRIPLET})
set(CMAKE_ASM_COMPILER_TARGET ${TARGET_TRIPLET})
set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)
set(CMAKE_ASM_COMPILER_WORKS 1)

# Set sysroot for the compilers
set(CMAKE_SYSROOT ${SYSROOT_DIR})
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --sysroot=${SYSROOT_DIR} -target x86_64-unknown-linux-llvm -rtlib=compiler-rt -unwind=libunwind" CACHE STRING "C flags")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --sysroot=${SYSROOT_DIR} -target x86_64-unknown-linux-llvm -rtlib=compiler-rt -unwind=libunwind -stdlib=libc++ " CACHE STRING "CXX flags")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --sysroot=${SYSROOT_DIR} -target x86_64-unknown-linux-llvm -rtlib=compiler-rt -unwind=libunwind -stdlib=libc++ " CACHE STRING "Linker flags")

# Prevent CMake from adding implicitly linked libraries
set(CMAKE_C_IMPLICIT_LINK_LIBRARIES "")
set(CMAKE_CXX_IMPLICIT_LINK_LIBRARIES "")

# Set the library and include paths
set(CMAKE_LIBRARY_PATH "${SYSROOT_DIR}/lib;${SYSROOT_DIR}/usr/lib")
set(CMAKE_INCLUDE_PATH "${SYSROOT_DIR}/include;${SYSROOT_DIR}/usr/include")

# Add runtime library path for compiler-rt
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -L${SYSROOT_DIR}/lib/clang/21/lib/x86_64-unknown-linux-llvm")

# Configure pkg-config for cross-compilation
set(ENV{PKG_CONFIG_PATH} "")
set(ENV{PKG_CONFIG_LIBDIR} "${SYSROOT_DIR}/usr/lib/pkgconfig:${SYSROOT_DIR}/usr/share/pkgconfig")
set(ENV{PKG_CONFIG_SYSROOT_DIR} "${SYSROOT_DIR}")

# Ensure we're not using features from the host
set(CMAKE_CROSSCOMPILING TRUE)
