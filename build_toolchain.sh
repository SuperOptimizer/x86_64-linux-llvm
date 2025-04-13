#!/usr/bin/env bash
set -euo pipefail
# Configuration
JOBS=$(nproc)
# Directories
HOME_DIR="$HOME"
WORK_DIR="${HOME_DIR}/build"
SRC_DIR="${HOME_DIR}/src"
SYSROOT_DIR="${HOME_DIR}/sysroot"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

if [ ! -d "${SRC_DIR}/linux" ]; then
    cd "${SRC_DIR}"
    git clone --depth 1 https://github.com/torvalds/linux.git
fi

# Install kernel headers to sysroot
cd "${SRC_DIR}/linux"
make headers_install ARCH=x86_64 INSTALL_HDR_PATH="${SYSROOT_DIR}/usr"


mkdir -p "${WORK_DIR}/stage1-build"
cd "${WORK_DIR}/stage1-build"
cmake -G Ninja "${SRC_DIR}/llvm-project/llvm" \
-DBUILD_SHARED_LIBS=OFF  \
-DCLANG_DEFAULT_CXX_STDLIB=libc++ \
-DCLANG_DEFAULT_LINKER=lld \
-DCLANG_DEFAULT_PIE_ON_LINUX=OFF \
-DCLANG_DEFAULT_RTLIB=compiler-rt \
-DCLANG_DEFAULT_UNWINDLIB=libunwind \
-DCLANG_ENABLE_PLUGINS=OFF \
-DCLANG_INSTALL_SHARED_LIBRARY=OFF \
-DCLANG_LINK_CLANG_DYLIB=OFF \
-DCMAKE_BUILD_TYPE=MinSizeRel \
-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
-DCMAKE_CXX_COMPILER=clang++-21 \
-DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
-DCMAKE_CXX_COMPILER_TARGET="x86_64-linux-musl" \
-DCMAKE_CXX_FLAGS="-w -g0  -march=native  "  \
-DCMAKE_CXX_STANDARD=20 \
-DCMAKE_C_COMPILER=clang-21 \
-DCMAKE_C_COMPILER_LAUNCHER=ccache \
-DCMAKE_C_COMPILER_TARGET="x86_64-linux-musl" \
-DCMAKE_C_FLAGS="-w -g0 -march=native " \
-DCMAKE_INSTALL_PREFIX="${SYSROOT_DIR}" \
-DCMAKE_INSTALL_RPATH="\$ORIGIN/../lib" \
-DCMAKE_TARGET_TRIPLE="x86_64-linux-musl" \
-DCOMPILER_RT_BUILD_BUILTINS=ON \
-DCOMPILER_RT_BUILD_CRT=ON \
-DCOMPILER_RT_BUILD_GWP_ASAN=OFF                       \
-DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
-DCOMPILER_RT_BUILD_MEMPROF=OFF \
-DCOMPILER_RT_BUILD_ORC=OFF \
-DCOMPILER_RT_BUILD_PROFILE=OFF \
-DCOMPILER_RT_BUILD_SANITIZERS=ON        \
-DCOMPILER_RT_BUILD_SCUDO_STANDALONE_WITH_LLVM_LIBC=OFF \
-DCOMPILER_RT_BUILD_XRAY=OFF \
-DCOMPILER_RT_CXX_LIBRARY=libcxx \
-DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="x86_64-linux-musl" \
-DCOMPILER_RT_ENABLE_STATIC_UNWINDER=ON \
-DCOMPILER_RT_ENABLE_THREADS=ON \
-DCOMPILER_RT_EXTERNALIZE_DEBUGINFO=OFF \
-DCOMPILER_RT_SCUDO_STANDALONE_BUILD_SHARED=OFF        \
-DCOMPILER_RT_STATIC_CXX_LIBRARY=ON \
-DCOMPILER_RT_USE_ATOMIC_LIBRARY=ON \
-DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON \
-DCOMPILER_RT_USE_LLVM_UNWINDER=ON \
-DLIBCXXABI_ENABLE_ASSERTIONS=OFF \
-DLIBCXXABI_ENABLE_FORGIVING_DYNAMIC_CAST=ON \
-DLIBCXXABI_ENABLE_STATIC=ON \
-DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
-DLIBCXXABI_ENABLE_THREADS=ON \
-DLIBCXXABI_HERMETIC_STATIC_LIBRARY=ON \
-DLIBCXXABI_INSTALL_SHARED_LIBRARY=OFF \
-DLIBCXXABI_INSTALL_STATIC_LIBRARY=ON \
-DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY=ON \
-DLIBCXXABI_USE_COMPILER_RT=ON \
-DLIBCXXABI_USE_LLVM_UNWINDER=ON \
-DLIBCXX_ABI_UNSTABLE=ON \
-DLIBCXX_CXX_ABI=libcxxabi \
-DLIBCXX_ENABLE_EXCEPTIONS=OFF \
-DLIBCXX_ENABLE_FILESYSTEM=ON \
-DLIBCXX_ENABLE_LOCALIZATION=OFF \
-DLIBCXX_ENABLE_MONOTONIC_CLOCK=ON \
-DLIBCXX_ENABLE_RANDOM_DEVICE=ON \
-DLIBCXX_ENABLE_RTTI=OFF \
-DLIBCXX_ENABLE_SHARED=OFF \
-DLIBCXX_ENABLE_SHARED_LIBRARY=OFF \
-DLIBCXX_ENABLE_STATIC=ON \
-DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
-DLIBCXX_ENABLE_THREADS=ON \
-DLIBCXX_ENABLE_TIME_ZONE_DATABASE=OFF \
-DLIBCXX_ENABLE_UNICODE=OFF \
-DLIBCXX_ENABLE_WIDE_CHARACTERS=OFF \
-DLIBCXX_HAS_MUSL_LIBC=OFF \
-DLIBCXX_HAS_PTHREAD_API=ON \
-DLIBCXX_HAS_TERMINAL_AVAILABLE=OFF \
-DLIBCXX_HERMETIC_STATIC_LIBRARY=ON \
-DLIBCXX_INCLUDE_TESTS=OFF \
-DLIBCXX_INSTALL_SHARED_LIBRARY=OFF \
-DLIBCXX_INSTALL_STATIC_LIBRARY=ON \
-DLIBCXX_STATICALLY_LINK_ABI_IN_STATIC_LIBRARY=ON \
-DLIBCXX_SUPPORTED_C_LIBRARIES=system \
-DLIBCXX_SUPPORTED_HARDENING_MODES=none \
-DLIBCXX_USE_COMPILER_RT=ON \
-DLIBC_CONF_ERRNO_MODE=LIBC_ERRNO_MODE_SHARED \
-DLIBC_CONF_ERRNO_MODE=LIBC_ERRNO_MODE_SHARED \
-DLIBC_ENABLE_USE_BY_CLANG=ON \
-DLIBC_ENABLE_USE_BY_CLANG=ON \
-DLIBC_ENABLE_WIDE_CHARACTERS=OFF \
-DLIBUNWIND_ENABLE_ASSERTIONS=OFF \
-DLIBUNWIND_ENABLE_PEDANTIC=OFF \
-DLIBUNWIND_ENABLE_SHARED=OFF \
-DLIBUNWIND_ENABLE_STATIC=ON \
-DLIBUNWIND_ENABLE_THREADS=ON \
-DLIBUNWIND_HIDE_SYMBOLS=ON \
-DLIBUNWIND_INSTALL_SHARED_LIBRARY=OFF \
-DLIBUNWIND_INSTALL_STATIC_LIBRARY=ON \
-DLIBUNWIND_USE_COMPILER_RT=ON \
-DLLDB_DISABLE_CURSES=ON \
-DLLDB_DISABLE_LIBEDIT=ON \
-DLLDB_DISABLE_PYTHON=ON \
-DLLDB_ENABLE_LIBXML2=OFF \
-DLLDB_ENABLE_LUA=OFF \
-DLLDB_ENABLE_LZMA=OFF  \
-DLLVM_BUILD_LLVM_C_DYLIB=OFF \
-DLLVM_BUILD_LLVM_DYLIB=OFF \
-DLLVM_BUILD_STATIC=ON \
-DLLVM_CCACHE_BUILD=ON \
-DLLVM_DEFAULT_TARGET_TRIPLE=x86_64-linux-musl \
-DLLVM_DYLIB_EXPORT_INLINES=OFF \
-DLLVM_ENABLE_EH=OFF \
-DLLVM_ENABLE_EXPENSIVE_CHECKS=OFF \
-DLLVM_ENABLE_LIBCXX=ON \
-DLLVM_ENABLE_LIBPFM=ON \
-DLLVM_ENABLE_LLD=ON \
-DLLVM_ENABLE_LLVM_LIBC=ON \
-DLLVM_ENABLE_MODULES=OFF \
-DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON \
-DLLVM_ENABLE_PIC=OFF \
-DLLVM_ENABLE_PLUGINS=OFF \
-DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld" \
-DLLVM_ENABLE_RTTI=OFF \
-DLLVM_ENABLE_RUNTIMES="libc;compiler-rt;libunwind;libcxx;libcxxabi" \
-DLLVM_ENABLE_THREADS=ON \
-DLLVM_ENABLE_UNWIND_TABLES=OFF \
-DLLVM_EXTERNALIZE_DEBUGINFO=OFF \
-DLLVM_INCLUDE_BENCHMARKS=OFF \
-DLLVM_INCLUDE_EXAMPLES=OFF \
-DLLVM_INCLUDE_TESTS=OFF \
-DLLVM_INCLUDE_TOOLS=ON \
-DLLVM_INSTALL_TOOLCHAIN_ONLY=OFF \
-DLLVM_INSTALL_UTILS=OFF \
-DLLVM_LIBC_FULL_BUILD=OFF \
-DLLVM_LIBC_INCLUDE_SCUDO=OFF \
-DLLVM_LINK_LLVM_DYLIB=OFF \
-DLLVM_PARALLEL_COMPILE_JOBS=32 \
-DLLVM_PARALLEL_LINK_JOBS=8 \
-DLLVM_PARALLEL_TABLEGEN_JOBS=32 \
-DLLVM_STATIC_LINK_CXX_STDLIB=ON \
-DLLVM_TARGETS_TO_BUILD=X86 \
-DLLVM_TARGET_ARCH="X86" \
-DLLVM_UNREACHABLE_OPTIMIZE=ON  \
-DRUNTIMES_x86_64-linux-musl_BUILD_SHARED_LIBS=OFF \
-DRUNTIMES_x86_64-linux-musl_CMAKE_BUILD_TYPE=MinSizeRel \
-DRUNTIMES_x86_64-linux-musl_CMAKE_BUILD_WITH_INSTALL_RPATH=ON \
-DRUNTIMES_x86_64-linux-musl_CMAKE_CXX_COMPILER=clang++-21 \
-DRUNTIMES_x86_64-linux-musl_CMAKE_CXX_COMPILER_LAUNCHER=ccache \
-DRUNTIMES_x86_64-linux-musl_CMAKE_CXX_COMPILER_TARGET="x86_64-linux-musl" \
-DRUNTIMES_x86_64-linux-musl_CMAKE_CXX_FLAGS="-w -g0  -march=native  "  \
-DRUNTIMES_x86_64-linux-musl_CMAKE_CXX_STANDARD=20 \
-DRUNTIMES_x86_64-linux-musl_CMAKE_C_COMPILER=clang-21 \
-DRUNTIMES_x86_64-linux-musl_CMAKE_C_COMPILER_LAUNCHER=ccache \
-DRUNTIMES_x86_64-linux-musl_CMAKE_C_COMPILER_TARGET="x86_64-linux-musl" \
-DRUNTIMES_x86_64-linux-musl_CMAKE_C_FLAGS="-w -g0 -march=native " \
-DRUNTIMES_x86_64-linux-musl_CMAKE_INSTALL_PREFIX="${SYSROOT_DIR}" \
-DRUNTIMES_x86_64-linux-musl_CMAKE_INSTALL_RPATH="\$ORIGIN/../lib" \
-DRUNTIMES_x86_64-linux-musl_CMAKE_TARGET_TRIPLE="x86_64-linux-musl" \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_BUILTINS=ON \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_CRT=ON \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_GWP_ASAN=OFF                       \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_LIBFUZZER=OFF \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_MEMPROF=OFF \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_ORC=OFF \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_PROFILE=OFF \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_SANITIZERS=ON        \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_SCUDO_STANDALONE_WITH_LLVM_LIBC=OFF \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_XRAY=OFF \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_CXX_LIBRARY=libcxx \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_DEFAULT_TARGET_TRIPLE="x86_64-linux-musl" \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_ENABLE_STATIC_UNWINDER=ON \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_ENABLE_THREADS=ON \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_EXTERNALIZE_DEBUGINFO=OFF \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_SCUDO_STANDALONE_BUILD_SHARED=OFF        \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_STATIC_CXX_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_USE_ATOMIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_USE_BUILTINS_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_USE_LLVM_UNWINDER=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_ENABLE_ASSERTIONS=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_ENABLE_FORGIVING_DYNAMIC_CAST=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_ENABLE_STATIC=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_ENABLE_THREADS=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_HERMETIC_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_INSTALL_SHARED_LIBRARY=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_INSTALL_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_USE_COMPILER_RT=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_USE_LLVM_UNWINDER=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ABI_UNSTABLE=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_CXX_ABI=libcxxabi \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_EXCEPTIONS=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_FILESYSTEM=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_LOCALIZATION=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_MONOTONIC_CLOCK=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_RANDOM_DEVICE=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_RTTI=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_SHARED=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_SHARED_LIBRARY=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_STATIC=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_THREADS=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_TIME_ZONE_DATABASE=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_UNICODE=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_WIDE_CHARACTERS=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_HAS_MUSL_LIBC=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_HAS_PTHREAD_API=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_HAS_TERMINAL_AVAILABLE=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_HERMETIC_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_INCLUDE_TESTS=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_INSTALL_SHARED_LIBRARY=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_INSTALL_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_STATICALLY_LINK_ABI_IN_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_SUPPORTED_C_LIBRARIES=system \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_SUPPORTED_HARDENING_MODES=none \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_USE_COMPILER_RT=ON \
-DRUNTIMES_x86_64-linux-musl_LIBC_CONF_ERRNO_MODE=LIBC_ERRNO_MODE_SHARED \
-DRUNTIMES_x86_64-linux-musl_LIBC_ENABLE_USE_BY_CLANG=ON \
-DRUNTIMES_x86_64-linux-musl_LIBC_ENABLE_WIDE_CHARACTERS=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_ENABLE_ASSERTIONS=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_ENABLE_PEDANTIC=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_ENABLE_SHARED=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_ENABLE_STATIC=ON \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_ENABLE_THREADS=ON \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_HIDE_SYMBOLS=ON \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_INSTALL_SHARED_LIBRARY=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_INSTALL_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_USE_COMPILER_RT=ON \
-DRUNTIMES_x86_64-linux-musl_LLVM_LIBC_FULL_BUILD=OFF \
-DRUNTIMES_x86_64-linux-musl_LLVM_LIBC_INCLUDE_SCUDO=OFF

ninja -k 0
ninja -k 0 install


mkdir -p "${WORK_DIR}/stage1-build"
cd "${WORK_DIR}/stage1-build"
cmake -G Ninja "${SRC_DIR}/llvm-project/llvm" \
-DBUILD_SHARED_LIBS=OFF  \
-DCLANG_DEFAULT_CXX_STDLIB=libc++ \
-DCLANG_DEFAULT_LINKER=lld \
-DCLANG_DEFAULT_PIE_ON_LINUX=OFF \
-DCLANG_DEFAULT_RTLIB=compiler-rt \
-DCLANG_DEFAULT_UNWINDLIB=libunwind \
-DCLANG_ENABLE_PLUGINS=OFF \
-DCLANG_INSTALL_SHARED_LIBRARY=OFF \
-DCLANG_LINK_CLANG_DYLIB=OFF \
-DCMAKE_BUILD_TYPE=MinSizeRel \
-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
-DCMAKE_CXX_COMPILER=clang++-21 \
-DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
-DCMAKE_CXX_COMPILER_TARGET="x86_64-linux-musl" \
-DCMAKE_CXX_FLAGS="-w -g0  -march=native  "  \
-DCMAKE_CXX_STANDARD=20 \
-DCMAKE_C_COMPILER=clang-21 \
-DCMAKE_C_COMPILER_LAUNCHER=ccache \
-DCMAKE_C_COMPILER_TARGET="x86_64-linux-musl" \
-DCMAKE_C_FLAGS="-w -g0 -march=native " \
-DCMAKE_INSTALL_PREFIX="${SYSROOT_DIR}" \
-DCMAKE_INSTALL_RPATH="\$ORIGIN/../lib" \
-DCMAKE_TARGET_TRIPLE="x86_64-linux-musl" \
-DCOMPILER_RT_BUILD_BUILTINS=ON \
-DCOMPILER_RT_BUILD_CRT=ON \
-DCOMPILER_RT_BUILD_GWP_ASAN=OFF                       \
-DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
-DCOMPILER_RT_BUILD_MEMPROF=OFF \
-DCOMPILER_RT_BUILD_ORC=OFF \
-DCOMPILER_RT_BUILD_PROFILE=OFF \
-DCOMPILER_RT_BUILD_SANITIZERS=ON        \
-DCOMPILER_RT_BUILD_SCUDO_STANDALONE_WITH_LLVM_LIBC=OFF \
-DCOMPILER_RT_BUILD_XRAY=OFF \
-DCOMPILER_RT_CXX_LIBRARY=libcxx \
-DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="x86_64-linux-musl" \
-DCOMPILER_RT_ENABLE_STATIC_UNWINDER=ON \
-DCOMPILER_RT_ENABLE_THREADS=ON \
-DCOMPILER_RT_EXTERNALIZE_DEBUGINFO=OFF \
-DCOMPILER_RT_SCUDO_STANDALONE_BUILD_SHARED=OFF        \
-DCOMPILER_RT_STATIC_CXX_LIBRARY=ON \
-DCOMPILER_RT_USE_ATOMIC_LIBRARY=ON \
-DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON \
-DCOMPILER_RT_USE_LLVM_UNWINDER=ON \
-DLIBCXXABI_ENABLE_ASSERTIONS=OFF \
-DLIBCXXABI_ENABLE_FORGIVING_DYNAMIC_CAST=ON \
-DLIBCXXABI_ENABLE_STATIC=ON \
-DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
-DLIBCXXABI_ENABLE_THREADS=ON \
-DLIBCXXABI_HERMETIC_STATIC_LIBRARY=ON \
-DLIBCXXABI_INSTALL_SHARED_LIBRARY=OFF \
-DLIBCXXABI_INSTALL_STATIC_LIBRARY=ON \
-DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY=ON \
-DLIBCXXABI_USE_COMPILER_RT=ON \
-DLIBCXXABI_USE_LLVM_UNWINDER=ON \
-DLIBCXX_ABI_UNSTABLE=ON \
-DLIBCXX_CXX_ABI=libcxxabi \
-DLIBCXX_ENABLE_EXCEPTIONS=OFF \
-DLIBCXX_ENABLE_FILESYSTEM=ON \
-DLIBCXX_ENABLE_LOCALIZATION=OFF \
-DLIBCXX_ENABLE_MONOTONIC_CLOCK=ON \
-DLIBCXX_ENABLE_RANDOM_DEVICE=ON \
-DLIBCXX_ENABLE_RTTI=OFF \
-DLIBCXX_ENABLE_SHARED=OFF \
-DLIBCXX_ENABLE_SHARED_LIBRARY=OFF \
-DLIBCXX_ENABLE_STATIC=ON \
-DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
-DLIBCXX_ENABLE_THREADS=ON \
-DLIBCXX_ENABLE_TIME_ZONE_DATABASE=OFF \
-DLIBCXX_ENABLE_UNICODE=OFF \
-DLIBCXX_ENABLE_WIDE_CHARACTERS=OFF \
-DLIBCXX_HAS_MUSL_LIBC=OFF \
-DLIBCXX_HAS_PTHREAD_API=ON \
-DLIBCXX_HAS_TERMINAL_AVAILABLE=OFF \
-DLIBCXX_HERMETIC_STATIC_LIBRARY=ON \
-DLIBCXX_INCLUDE_TESTS=OFF \
-DLIBCXX_INSTALL_SHARED_LIBRARY=OFF \
-DLIBCXX_INSTALL_STATIC_LIBRARY=ON \
-DLIBCXX_STATICALLY_LINK_ABI_IN_STATIC_LIBRARY=ON \
-DLIBCXX_SUPPORTED_C_LIBRARIES=system \
-DLIBCXX_SUPPORTED_HARDENING_MODES=none \
-DLIBCXX_USE_COMPILER_RT=ON \
-DLIBC_CONF_ERRNO_MODE=LIBC_ERRNO_MODE_SHARED \
-DLIBC_CONF_ERRNO_MODE=LIBC_ERRNO_MODE_SHARED \
-DLIBC_ENABLE_USE_BY_CLANG=ON \
-DLIBC_ENABLE_USE_BY_CLANG=ON \
-DLIBC_ENABLE_WIDE_CHARACTERS=OFF \
-DLIBUNWIND_ENABLE_ASSERTIONS=OFF \
-DLIBUNWIND_ENABLE_PEDANTIC=OFF \
-DLIBUNWIND_ENABLE_SHARED=OFF \
-DLIBUNWIND_ENABLE_STATIC=ON \
-DLIBUNWIND_ENABLE_THREADS=ON \
-DLIBUNWIND_HIDE_SYMBOLS=ON \
-DLIBUNWIND_INSTALL_SHARED_LIBRARY=OFF \
-DLIBUNWIND_INSTALL_STATIC_LIBRARY=ON \
-DLIBUNWIND_USE_COMPILER_RT=ON \
-DLLDB_DISABLE_CURSES=ON \
-DLLDB_DISABLE_LIBEDIT=ON \
-DLLDB_DISABLE_PYTHON=ON \
-DLLDB_ENABLE_LIBXML2=OFF \
-DLLDB_ENABLE_LUA=OFF \
-DLLDB_ENABLE_LZMA=OFF  \
-DLLVM_BUILD_LLVM_C_DYLIB=OFF \
-DLLVM_BUILD_LLVM_DYLIB=OFF \
-DLLVM_BUILD_STATIC=ON \
-DLLVM_CCACHE_BUILD=ON \
-DLLVM_DEFAULT_TARGET_TRIPLE=x86_64-linux-musl \
-DLLVM_DYLIB_EXPORT_INLINES=OFF \
-DLLVM_ENABLE_EH=OFF \
-DLLVM_ENABLE_EXPENSIVE_CHECKS=OFF \
-DLLVM_ENABLE_LIBCXX=ON \
-DLLVM_ENABLE_LIBPFM=ON \
-DLLVM_ENABLE_LLD=ON \
-DLLVM_ENABLE_LLVM_LIBC=ON \
-DLLVM_ENABLE_MODULES=OFF \
-DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON \
-DLLVM_ENABLE_PIC=OFF \
-DLLVM_ENABLE_PLUGINS=OFF \
-DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld" \
-DLLVM_ENABLE_RTTI=OFF \
-DLLVM_ENABLE_RUNTIMES="libc;compiler-rt;libunwind;libcxx;libcxxabi" \
-DLLVM_ENABLE_THREADS=ON \
-DLLVM_ENABLE_UNWIND_TABLES=OFF \
-DLLVM_EXTERNALIZE_DEBUGINFO=OFF \
-DLLVM_INCLUDE_BENCHMARKS=OFF \
-DLLVM_INCLUDE_EXAMPLES=OFF \
-DLLVM_INCLUDE_TESTS=OFF \
-DLLVM_INCLUDE_TOOLS=ON \
-DLLVM_INSTALL_TOOLCHAIN_ONLY=OFF \
-DLLVM_INSTALL_UTILS=OFF \
-DLLVM_LIBC_FULL_BUILD=OFF \
-DLLVM_LIBC_INCLUDE_SCUDO=OFF \
-DLLVM_LINK_LLVM_DYLIB=OFF \
-DLLVM_PARALLEL_COMPILE_JOBS=32 \
-DLLVM_PARALLEL_LINK_JOBS=8 \
-DLLVM_PARALLEL_TABLEGEN_JOBS=32 \
-DLLVM_STATIC_LINK_CXX_STDLIB=ON \
-DLLVM_TARGETS_TO_BUILD=X86 \
-DLLVM_TARGET_ARCH="X86" \
-DLLVM_UNREACHABLE_OPTIMIZE=ON  \
-DRUNTIMES_x86_64-linux-musl_BUILD_SHARED_LIBS=OFF \
-DRUNTIMES_x86_64-linux-musl_CMAKE_BUILD_TYPE=MinSizeRel \
-DRUNTIMES_x86_64-linux-musl_CMAKE_BUILD_WITH_INSTALL_RPATH=ON \
-DRUNTIMES_x86_64-linux-musl_CMAKE_CXX_COMPILER=clang++-21 \
-DRUNTIMES_x86_64-linux-musl_CMAKE_CXX_COMPILER_LAUNCHER=ccache \
-DRUNTIMES_x86_64-linux-musl_CMAKE_CXX_COMPILER_TARGET="x86_64-linux-musl" \
-DRUNTIMES_x86_64-linux-musl_CMAKE_CXX_FLAGS="-w -g0  -march=native  "  \
-DRUNTIMES_x86_64-linux-musl_CMAKE_CXX_STANDARD=20 \
-DRUNTIMES_x86_64-linux-musl_CMAKE_C_COMPILER=clang-21 \
-DRUNTIMES_x86_64-linux-musl_CMAKE_C_COMPILER_LAUNCHER=ccache \
-DRUNTIMES_x86_64-linux-musl_CMAKE_C_COMPILER_TARGET="x86_64-linux-musl" \
-DRUNTIMES_x86_64-linux-musl_CMAKE_C_FLAGS="-w -g0 -march=native " \
-DRUNTIMES_x86_64-linux-musl_CMAKE_INSTALL_PREFIX="${SYSROOT_DIR}" \
-DRUNTIMES_x86_64-linux-musl_CMAKE_INSTALL_RPATH="\$ORIGIN/../lib" \
-DRUNTIMES_x86_64-linux-musl_CMAKE_TARGET_TRIPLE="x86_64-linux-musl" \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_BUILTINS=ON \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_CRT=ON \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_GWP_ASAN=OFF                       \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_LIBFUZZER=OFF \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_MEMPROF=OFF \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_ORC=OFF \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_PROFILE=OFF \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_SANITIZERS=ON        \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_SCUDO_STANDALONE_WITH_LLVM_LIBC=OFF \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_BUILD_XRAY=OFF \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_CXX_LIBRARY=libcxx \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_DEFAULT_TARGET_TRIPLE="x86_64-linux-musl" \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_ENABLE_STATIC_UNWINDER=ON \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_ENABLE_THREADS=ON \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_EXTERNALIZE_DEBUGINFO=OFF \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_SCUDO_STANDALONE_BUILD_SHARED=OFF        \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_STATIC_CXX_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_USE_ATOMIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_USE_BUILTINS_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_COMPILER_RT_USE_LLVM_UNWINDER=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_ENABLE_ASSERTIONS=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_ENABLE_FORGIVING_DYNAMIC_CAST=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_ENABLE_STATIC=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_ENABLE_THREADS=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_HERMETIC_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_INSTALL_SHARED_LIBRARY=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_INSTALL_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_USE_COMPILER_RT=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXXABI_USE_LLVM_UNWINDER=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ABI_UNSTABLE=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_CXX_ABI=libcxxabi \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_EXCEPTIONS=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_FILESYSTEM=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_LOCALIZATION=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_MONOTONIC_CLOCK=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_RANDOM_DEVICE=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_RTTI=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_SHARED=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_SHARED_LIBRARY=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_STATIC=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_THREADS=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_TIME_ZONE_DATABASE=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_UNICODE=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_ENABLE_WIDE_CHARACTERS=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_HAS_MUSL_LIBC=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_HAS_PTHREAD_API=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_HAS_TERMINAL_AVAILABLE=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_HERMETIC_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_INCLUDE_TESTS=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_INSTALL_SHARED_LIBRARY=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_INSTALL_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_STATICALLY_LINK_ABI_IN_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_SUPPORTED_C_LIBRARIES=system \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_SUPPORTED_HARDENING_MODES=none \
-DRUNTIMES_x86_64-linux-musl_LIBCXX_USE_COMPILER_RT=ON \
-DRUNTIMES_x86_64-linux-musl_LIBC_CONF_ERRNO_MODE=LIBC_ERRNO_MODE_SHARED \
-DRUNTIMES_x86_64-linux-musl_LIBC_ENABLE_USE_BY_CLANG=ON \
-DRUNTIMES_x86_64-linux-musl_LIBC_ENABLE_WIDE_CHARACTERS=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_ENABLE_ASSERTIONS=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_ENABLE_PEDANTIC=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_ENABLE_SHARED=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_ENABLE_STATIC=ON \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_ENABLE_THREADS=ON \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_HIDE_SYMBOLS=ON \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_INSTALL_SHARED_LIBRARY=OFF \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_INSTALL_STATIC_LIBRARY=ON \
-DRUNTIMES_x86_64-linux-musl_LIBUNWIND_USE_COMPILER_RT=ON \
-DRUNTIMES_x86_64-linux-musl_LLVM_LIBC_FULL_BUILD=OFF \
-DRUNTIMES_x86_64-linux-musl_LLVM_LIBC_INCLUDE_SCUDO=OFF

ninja -k 0
ninja -k 0 install