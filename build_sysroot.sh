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

if [ ! -d "${SRC_DIR}/linux" ]; then
    cd "${SRC_DIR}"
    git clone --depth 1 https://github.com/torvalds/linux.git
fi


if [ ! -d "${SRC_DIR}/llvm-project" ]; then
    cd "${SRC_DIR}"
    git clone --depth 1 https://github.com/SuperOptimizer/llvm-project.git
fi

if [ ! -d "${SRC_DIR}/glibc" ]; then
    cd "${SRC_DIR}"
    git clone --depth 1 https://sourceware.org/git/glibc.git
fi

if [ ! -d "${SRC_DIR}/gcc" ]; then
    cd "${SRC_DIR}"
    git clone --depth 1 git://gcc.gnu.org/git/gcc.git
fi




# Install kernel headers to sysroot
cd "${SRC_DIR}/linux"
make headers_install ARCH=x86_64 INSTALL_HDR_PATH="${SYSROOT_DIR}/usr"


# Set up sysroot with basic structure
mkdir -p "${SYSROOT_DIR}/usr/include"
mkdir -p "${SYSROOT_DIR}/usr/lib"
mkdir -p "${SYSROOT_DIR}/lib"
mkdir -p "${SYSROOT_DIR}/lib64"

# Build and install Glibc to the sysroot
cd "${SRC_DIR}/glibc"
mkdir -p build
cd build
../configure \
    --prefix="/usr" \
    --disable-werror \
    --enable-kernel=5.15.0 \
    --enable-stack-protector=strong \
    --enable-bind-now
make -j${JOBS}
make DESTDIR="${SYSROOT_DIR}" install

# Download GCC prerequisites
cd "${SRC_DIR}/gcc"
./contrib/download_prerequisites

# Create build directory for GCC
mkdir -p "${SRC_DIR}/gcc/build"
cd "${SRC_DIR}/gcc/build"

# Configure GCC to build both compilers and libraries
../configure \
    --prefix="/usr" \
    --disable-multilib \
    --enable-languages=c,c++ \
    --disable-bootstrap \
    --with-system-zlib \
    --enable-shared \
    --enable-threads=posix \
    --enable-__cxa_atexit \
    --enable-clocale=gnu \
    --enable-checking=release \
    --with-sysroot="${SYSROOT_DIR}"

# Build everything
make -j${JOBS}

# Install GCC to sysroot
make DESTDIR="${SYSROOT_DIR}" install

# Ensure the start files are in the right place
if [ ! -f "${SYSROOT_DIR}/usr/lib/crti.o" ]; then
    echo "Copying system crti.o to sysroot..."
    cp /usr/lib/x86_64-linux-gnu/crti.o "${SYSROOT_DIR}/usr/lib/"
fi

if [ ! -f "${SYSROOT_DIR}/usr/lib/crtn.o" ]; then
    echo "Copying system crtn.o to sysroot..."
    cp /usr/lib/x86_64-linux-gnu/crtn.o "${SYSROOT_DIR}/usr/lib/"
fi

if [ ! -f "${SYSROOT_DIR}/usr/lib/crt1.o" ]; then
    echo "Copying system crt1.o to sysroot..."
    cp /usr/lib/x86_64-linux-gnu/crt1.o "${SYSROOT_DIR}/usr/lib/"
fi

# Create symlinks for libraries if needed
cd "${SYSROOT_DIR}/lib"
if [ ! -L "libc.so.6" ] && [ -f "${SYSROOT_DIR}/usr/lib/libc.so.6" ]; then
    ln -sf ../usr/lib/libc.so.6 libc.so.6
fi