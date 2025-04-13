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

# Create necessary directories if they don't exist
mkdir -p "${SRC_DIR}" "${SYSROOT_DIR}" "${SYSROOT_DIR}/usr"

if [ ! -d "${SRC_DIR}/linux" ]; then
    cd "${SRC_DIR}"
    git clone --depth 1 https://github.com/torvalds/linux.git
fi

if [ ! -d "${SRC_DIR}/llvm-project" ]; then
    cd "${SRC_DIR}"
    git clone --depth 1 https://github.com/SuperOptimizer/llvm-project.git
fi

# Checkout musl libc
if [ ! -d "${SRC_DIR}/musl" ]; then
    cd "${SRC_DIR}"
    git clone --depth 1 https://git.musl-libc.org/git/musl
fi

# Install kernel headers to sysroot
cd "${SRC_DIR}/linux"
make headers_install ARCH=x86_64 INSTALL_HDR_PATH="${SYSROOT_DIR}/usr"

# Configure and build musl
cd "${SRC_DIR}/musl"
# Clean previous builds if any
make clean || true

CC=clang CFLAGS="-O2 -fPIC" ./configure --prefix="${SYSROOT_DIR}" --disable-shared
make -j${JOBS} CC=clang
make install

