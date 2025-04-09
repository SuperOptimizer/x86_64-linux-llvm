#!/bin/bash
set -euo pipefail

# Configuration
JOBS=$(nproc)

# Directories
HOME_DIR="$HOME"
WORK_DIR="${HOME_DIR}/build"
SRC_DIR="${HOME_DIR}/src"
SYSROOT_DIR="${HOME_DIR}/sysroot"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
BUILD_DIR="${WORK_DIR}"
CORES=$JOBS

echo "==== Creating directories ===="
mkdir -p "${SRC_DIR}" "${WORK_DIR}" "${SYSROOT_DIR}"
mkdir -p "${SYSROOT_DIR}/usr/lib" "${SYSROOT_DIR}/usr/include"

# Clone Linux kernel and install headers
if [ ! -d "${SRC_DIR}/linux" ]; then
    echo "==== Cloning Linux kernel ===="
    cd "${SRC_DIR}"
    git clone --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
fi

# Install Linux headers to sysroot
echo "==== Installing Linux headers ===="
cd "${SRC_DIR}/linux"
make headers_install INSTALL_HDR_PATH="${SYSROOT_DIR}/usr"

# Clone the latest glibc from git
echo "==== Cloning latest glibc from git ===="
cd "${SRC_DIR}"
if [ ! -d "glibc" ]; then
    git clone --depth 1 https://sourceware.org/git/glibc.git
else
    cd "${SRC_DIR}/glibc"
    git pull
    cd "${SRC_DIR}"
fi

# Clone GCC for runtime libraries and full compiler
echo "==== Cloning GCC for compiler and runtime libraries ===="
cd "${SRC_DIR}"
if [ ! -d "gcc" ]; then
    git clone --depth 1 https://gcc.gnu.org/git/gcc.git
else
    cd "${SRC_DIR}/gcc"
    git pull
    cd "${SRC_DIR}"
fi

# Clone dependencies for GCC
echo "==== Fetching GCC prerequisites ===="
cd "${SRC_DIR}/gcc"
./contrib/download_prerequisites

# Build and install glibc
echo "==== Building and installing glibc ===="
mkdir -p "${WORK_DIR}/glibc-build"
cd "${WORK_DIR}/glibc-build"
"${SRC_DIR}/glibc/configure" \
    --prefix=/usr \
    --with-headers="${SYSROOT_DIR}/usr/include" \
    --disable-werror

make -j"${CORES}"
make DESTDIR="${SYSROOT_DIR}" install

# Build and install full GCC, G++ and all runtime libraries
echo "==== Building full GCC compiler suite and runtime libraries ===="
mkdir -p "${WORK_DIR}/gcc-build"
cd "${WORK_DIR}/gcc-build"

# Configure GCC for a full build including compilers, optimized for modern systems
"${SRC_DIR}/gcc/configure" \
    --prefix=/usr \
    --enable-languages=c,c++ \
    --with-system-zlib \
    --with-glibc-version=2.41 \
    --enable-shared \
    --enable-static \
    --enable-threads=posix \
    --enable-__cxa_atexit \
    --enable-clocale=gnu \
    --enable-checking=release \
    --disable-multilib \
    --disable-libsanitizer \
    --disable-libvtv \
    --disable-libcilkrts \
    --disable-libstdcxx-pch \
    --disable-bootstrap \
    --disable-libmudflap \
    --disable-libgomp \
    --disable-libquadmath

# Build everything (compilers and libraries)
echo "==== Building full GCC toolchain ===="
make -j"${CORES}"

# Install everything to the sysroot
echo "==== Installing full GCC toolchain to sysroot ===="
make DESTDIR="${SYSROOT_DIR}" install

echo "==== Build complete! ===="
echo "GCC and G++ with all runtime libraries have been installed to ${SYSROOT_DIR}"