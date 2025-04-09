#needs a recent llvm-toolchain. on ubuntu use https://apt.llvm.org/llvm.sh and download all packages for v 21

#!/usr/bin/env bash
set -euo pipefail
# Configuration
JOBS=$(nproc)
# Directories
HOME_DIR="$HOME"
WORK_DIR="${HOME_DIR}/build"
SRC_DIR="${HOME_DIR}/src"
SYSROOT_DIR="${HOME_DIR}/sysroot"
SYSROOT2_DIR="${HOME_DIR}/sysroot2"
TOOLCHAIN_DIR="${HOME_DIR}/toolchain"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Clone Linux kernel and install headers
if [ ! -d "${SRC_DIR}/linux" ]; then
    cd "${SRC_DIR}"
    git clone --depth 1 https://github.com/torvalds/linux.git
fi

# Install kernel headers to sysroot
cd "${SRC_DIR}/linux"
make headers_install ARCH=x86_64 INSTALL_HDR_PATH="${SYSROOT_DIR}/usr"

# Clone Linux kernel and install headers
if [ ! -d "${SRC_DIR}/llvm-project" ]; then
    cd "${SRC_DIR}"
    git clone --depth 1 https://github.com/SuperOptimizer/llvm-project.git
fi

# Continue with the runtime build
mkdir -p "${WORK_DIR}/stage1-build"
cd "${WORK_DIR}/stage1-build"
cmake -G Ninja "${SRC_DIR}/llvm-project/llvm" \
-DBUILD_SHARED_LIBS=OFF \
-DCLANG_DEFAULT_CXX_STDLIB=libc++ \
-DCLANG_DEFAULT_LINKER=lld \
-DCLANG_DEFAULT_PIE_ON_LINUX=ON \
-DCLANG_DEFAULT_RTLIB=compiler-rt \
-DCLANG_DEFAULT_UNWINDLIB=libunwind \
-DCMAKE_BUILD_TYPE=MinSizeRel \
-DCMAKE_CXX_COMPILER=clang++-21 \
-DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
-DCMAKE_CXX_FLAGS=" -w -Os -g0    " \
-DCMAKE_CXX_STANDARD=20 \
-DCMAKE_C_COMPILER=clang-21 \
-DCMAKE_C_COMPILER_LAUNCHER=ccache \
-DCMAKE_C_FLAGS=" -w -Os -g0   " \
-DCMAKE_EXE_LINKER_FLAGS="  " \
-DCMAKE_INSTALL_PREFIX="${SYSROOT_DIR}" \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_BUILTINS=ON \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_CRT=ON \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_GWP_ASAN=OFF                       \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_LIBFUZZER=OFF \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_ORC=OFF \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_PROFILE=OFF \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_PROFILE=OFF \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_SANITIZERS=ON        \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_SCUDO_STANDALONE_WITH_LLVM_LIBC=ON \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_XRAY=OFF \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_CXX_LIBRARY=libcxx \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_ENABLE_STATIC_UNWINDER=ON \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_ENABLE_THREADS=OFF \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_SCUDO_STANDALONE_BUILD_SHARED=OFF        \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_STATIC_CXX_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_USE_ATOMIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_USE_BUILTINS_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_USE_LLVM_UNWINDER=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXXABI_ENABLE_ASSERTIONS=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXXABI_ENABLE_FORGIVING_DYNAMIC_CAST=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXXABI_ENABLE_STATIC=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXXABI_ENABLE_THREADS=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXXABI_USE_COMPILER_RT=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXXABI_USE_LLVM_UNWINDER=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ABI_UNSTABLE=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_EXCEPTIONS=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_FILESYSTEM=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_LOCALIZATION=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_MONOTONIC_CLOCK=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_RANDOM_DEVICE=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_RTTI=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_SHARED=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_STATIC=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_THREADS=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_UNICODE=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_WIDE_CHARACTERS=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_HAS_TERMINAL_AVAILABLE=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_INCLUDE_TESTS=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_STATICALLY_LINK_ABI_IN_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_SUPPORTED_C_LIBRARIES=system \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_SUPPORTED_HARDENING_MODES=none \
-DRUNTIMES_x86_64-linux-gnu_LIBC_ENABLE_USE_BY_CLANG=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBC_ENABLE_WIDE_CHARACTERS=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBUNWIND_ENABLE_ASSERTIONS=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBUNWIND_ENABLE_PEDANTIC=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBUNWIND_ENABLE_SHARED=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBUNWIND_ENABLE_STATIC=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBUNWIND_ENABLE_THREADS=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBUNWIND_USE_COMPILER_RT=ON \
-DLLVM_CCACHE_BUILD=ON \
-DLLVM_DEFAULT_TARGET_TRIPLE=x86_64-unknown-linux-gnu \
-DLLVM_ENABLE_EH=OFF \
-DLLVM_ENABLE_EXPENSIVE_CHECKS=OFF \
-DLLVM_ENABLE_LIBCXX=ON \
-DLLVM_ENABLE_LIBPFM=OFF \
-DLLVM_ENABLE_LLD=ON \
-DLLVM_ENABLE_LLVM_LIBC=ON \
-DLLVM_ENABLE_MODULES=OFF \
-DLLVM_ENABLE_RTTI=OFF \
-DLLVM_ENABLE_PROJECTS="clang;lld" \
-DLLVM_ENABLE_RUNTIMES="libc;compiler-rt;libunwind;libcxx;libcxxabi" \
-DLLVM_ENABLE_THREADS=OFF \
-DLLVM_ENABLE_UNWIND_TABLES=OFF \
-DLLVM_INCLUDE_BENCHMARKS=OFF \
-DLLVM_INCLUDE_EXAMPLES=OFF \
-DLLVM_INCLUDE_TESTS=OFF \
-DLLVM_INCLUDE_TOOLS=ON \
-DLLVM_INSTALL_UTILS=OFF \
-DLLVM_LIBC_FULL_BUILD=ON \
-DLLVM_LIBC_INCLUDE_SCUDO=ON \
-DRUNTIMES_x86_64-linux-gnu_LLVM_LIBC_FULL_BUILD=ON \
-DRUNTIMES_x86_64-linux-gnu_LLVM_LIBC_INCLUDE_SCUDO=ON \
-DLLVM_STATIC_LINK_CXX_STDLIB=ON \
-DLLVM_UNREACHABLE_OPTIMIZE=ON \
-DRUNTIMES_x86_64-linux-gnu_SANITIZER_USE_STATIC_CXX_ABI=ON \
-DRUNTIMES_x86_64-linux-gnu_SANITIZER_USE_STATIC_LLVM_UNWINDER=ON


ninja
ninja   install


# Continue with the runtime build
mkdir -p "${WORK_DIR}/final-build"
cd "${WORK_DIR}/final-build"
cmake -G Ninja "${SRC_DIR}/llvm-project/llvm" \
-DCMAKE_SYSROOT="${SYSROOT_DIR}" \
-DCMAKE_LIBRARY_PATH="${SYSROOT_DIR}/lib/x86_64-unknown-linux-gnu" \
-DCLANG_DEFAULT_CXX_STDLIB=libc++ \
-DCLANG_DEFAULT_LINKER=lld \
-DCLANG_DEFAULT_RTLIB=compiler-rt \
-DCLANG_DEFAULT_UNWINDLIB=libunwind \
-DLLVM_LIBC_FULL_BUILD=ON \
-DCLANG_DEFAULT_PIE_ON_LINUX=ON \
-DLLVM_DEFAULT_TARGET_TRIPLE=x86_64-unknown-linux-gnu \
-DBUILD_SHARED_LIBS=OFF \
-DCMAKE_BUILD_TYPE=MinSizeRel \
-DCMAKE_CXX_COMPILER=clang++-21 \
-DCMAKE_CXX_COMPILER_WORKS=1 \
-DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
-DCMAKE_CXX_FLAGS=" -nostdinc -nostdinc++ -isystem ${SYSROOT_DIR}/include/c++/v1/  -isystem ${SYSROOT_DIR}/include -isystem ${SYSROOT_DIR}/usr/include  --sysroot ${SYSROOT_DIR} -static -w -Os -g0 -unwind=libunwind --rtlib=compiler-rt -stdlib=libc++   " \
-DCMAKE_CXX_STANDARD=20 \
-DCMAKE_C_COMPILER=clang-21 \
-DCMAKE_C_COMPILER_WORKS=1 \
-DCMAKE_C_COMPILER_LAUNCHER=ccache \
-DCMAKE_C_FLAGS=" -nostdinc -nostdinc++ -isystem ${SYSROOT_DIR}/include -isystem ${SYSROOT_DIR}/usr/include --sysroot ${SYSROOT_DIR} -static -w -Os -g0 -unwind=libunwind --rtlib=compiler-rt " \
-DCMAKE_EXE_LINKER_FLAGS=" --sysroot ${SYSROOT_DIR} -static -unwind=libunwind --rtlib=compiler-rt -stdlib=libc++ " \
-DCMAKE_INSTALL_PREFIX="${SYSROOT2_DIR}" \
-DLIBC_ENABLE_USE_BY_CLANG=OFF \
-DLLVM_CCACHE_BUILD=ON \
-DLLVM_ENABLE_EH=OFF \
-DLLVM_ENABLE_EXPENSIVE_CHECKS=OFF \
-DLLVM_ENABLE_LIBCXX=ON \
-DLLVM_ENABLE_LIBPFM=OFF \
-DLLVM_ENABLE_LLD=ON \
-DLLVM_ENABLE_LLVM_LIBC=ON \
-DLLVM_ENABLE_MODULES=OFF \
-DLLVM_ENABLE_PROJECTS="clang;lld" \
-DLLVM_ENABLE_RTTI=OFF \
-DLLVM_ENABLE_RUNTIMES="libc;compiler-rt;libunwind;libcxx;libcxxabi" \
-DLLVM_ENABLE_THREADS=OFF \
-DLLVM_ENABLE_UNWIND_TABLES=OFF \
-DLLVM_INCLUDE_BENCHMARKS=OFF \
-DLLVM_INCLUDE_EXAMPLES=OFF \
-DLLVM_INCLUDE_TESTS=OFF \
-DLLVM_INCLUDE_TOOLS=ON \
-DLLVM_INSTALL_UTILS=OFF \
-DLLVM_LIBC_INCLUDE_SCUDO=ON \
-DLLVM_STATIC_LINK_CXX_STDLIB=ON \
-DLLVM_UNREACHABLE_OPTIMIZE=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBC_ENABLE_WIDE_CHARACTERS=OFF \
-DRUNTIMES_x86_64-linux-gnu_CMAKE_LIBRARY_PATH="${SYSROOT_DIR}/lib/x86_64-unknown-linux-gnu" \
-DRUNTIMES_x86_64-linux-gnu_LLVM_LIBC_FULL_BUILD=ON \
-DRUNTIMES_x86_64-linux-gnu_CMAKE_SYSROOT="${SYSROOT_DIR}" \
-DRUNTIMES_x86_64-linux-gnu_CMAKE_CXX_COMPILER=clang++-21 \
-DRUNTIMES_x86_64-linux-gnu_CMAKE_CXX_COMPILER_LAUNCHER=ccache \
-DRUNTIMES_x86_64-linux-gnu_CMAKE_CXX_FLAGS=" -nostdinc -nostdinc++ -isystem ${SYSROOT_DIR}/include/c++/v1/  -isystem ${SYSROOT_DIR}/include -isystem ${SYSROOT_DIR}/usr/include  --sysroot ${SYSROOT_DIR}  -w -Os -g0    " \
-DRUNTIMES_x86_64-linux-gnu_CMAKE_CXX_STANDARD=20 \
-DRUNTIMES_x86_64-linux-gnu_CMAKE_C_COMPILER=clang-21 \
-DRUNTIMES_x86_64-linux-gnu_CMAKE_C_COMPILER_LAUNCHER=ccache \
-DRUNTIMES_x86_64-linux-gnu_CMAKE_C_FLAGS=" -nostdinc -nostdinc++ -isystem ${SYSROOT_DIR}/include -isystem ${SYSROOT_DIR}/usr/include  --sysroot ${SYSROOT_DIR} -w -Os -g0   " \
-DRUNTIMES_x86_64-linux-gnu_CMAKE_EXE_LINKER_FLAGS=" --sysroot ${SYSROOT_DIR}  " \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_BUILTINS=ON \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_CRT=ON \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_GWP_ASAN=OFF                       \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_LIBFUZZER=OFF \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_ORC=OFF \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_PROFILE=OFF \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_PROFILE=OFF \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_SANITIZERS=ON        \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_SCUDO_STANDALONE_WITH_LLVM_LIBC=ON \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_BUILD_XRAY=OFF \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_CXX_LIBRARY=libcxx \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_ENABLE_STATIC_UNWINDER=ON \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_ENABLE_THREADS=OFF \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_SCUDO_STANDALONE_BUILD_SHARED=OFF        \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_STATIC_CXX_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_USE_ATOMIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_USE_BUILTINS_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-gnu_COMPILER_RT_USE_LLVM_UNWINDER=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXXABI_ENABLE_ASSERTIONS=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXXABI_ENABLE_FORGIVING_DYNAMIC_CAST=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXXABI_ENABLE_STATIC=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXXABI_ENABLE_THREADS=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXXABI_USE_COMPILER_RT=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXXABI_USE_LLVM_UNWINDER=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ABI_UNSTABLE=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_EXCEPTIONS=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_FILESYSTEM=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_LOCALIZATION=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_MONOTONIC_CLOCK=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_RANDOM_DEVICE=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_RTTI=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_SHARED=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_STATIC=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_THREADS=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_UNICODE=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_ENABLE_WIDE_CHARACTERS=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_HAS_TERMINAL_AVAILABLE=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_INCLUDE_TESTS=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_STATICALLY_LINK_ABI_IN_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_SUPPORTED_C_LIBRARIES=system \
-DRUNTIMES_x86_64-linux-gnu_LIBCXX_SUPPORTED_HARDENING_MODES=none \
-DRUNTIMES_x86_64-linux-gnu_LIBC_ENABLE_USE_BY_CLANG=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBUNWIND_ENABLE_ASSERTIONS=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBUNWIND_ENABLE_PEDANTIC=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBUNWIND_ENABLE_SHARED=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBUNWIND_ENABLE_STATIC=ON \
-DRUNTIMES_x86_64-linux-gnu_LIBUNWIND_ENABLE_THREADS=OFF \
-DRUNTIMES_x86_64-linux-gnu_LIBUNWIND_USE_COMPILER_RT=ON \
-DRUNTIMES_x86_64-linux-gnu_LLVM_LIBC_INCLUDE_SCUDO=ON \
-DRUNTIMES_x86_64-linux-gnu_SANITIZER_USE_STATIC_CXX_ABI=ON \
-DRUNTIMES_x86_64-linux-gnu_SANITIZER_USE_STATIC_LLVM_UNWINDER=ON

ninja
ninja install