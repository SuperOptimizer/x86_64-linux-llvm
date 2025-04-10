#!/usr/bin/env bash
set -euo pipefail

# Configuration
JOBS=$(nproc)

# Directories
HOME_DIR="$HOME"
WORK_DIR="${HOME_DIR}/build"
SRC_DIR="${HOME_DIR}/src"
SYSROOT_DIR="${HOME_DIR}/sysroot"
KERNEL_BUILD_DIR="${WORK_DIR}/kernel-build"
COMPAT_DIR="${HOME_DIR}/x86_64-linux-llvm"

# Compile compatibility library
echo "Building compatibility library..."
cd "${COMPAT_DIR}"
${SYSROOT_DIR}/bin/clang -c libc_misc.c -o libc_misc.o -Wno-everything
${SYSROOT_DIR}/bin/clang -c syscall.s -o syscall.o
${SYSROOT_DIR}/bin/llvm-ar rcs libcompat.a libc_misc.o syscall.o

# Copy the compatibility library to the sysroot lib
cp libcompat.a "${SYSROOT_DIR}/lib/"

# Make sure the Linux kernel source is available
if [ ! -d "${SRC_DIR}/linux" ]; then
    cd "${SRC_DIR}"
    git clone --depth 1 https://github.com/torvalds/linux.git
fi

# Clean the kernel source tree first
cd "${SRC_DIR}/linux"
make mrproper


# Create kernel build directory
mkdir -p "${KERNEL_BUILD_DIR}"

# Following the LLVM-specific build instructions from the documentation
echo "CONFIG_X86_X32=n" | make O="${KERNEL_BUILD_DIR}" \
    ARCH=x86_64 \
    LLVM=1 \
    LLVM_IAS=1 \
    -j"${JOBS}" \
    CC="${SYSROOT_DIR}/bin/clang" \
    LD="${SYSROOT_DIR}/bin/ld.lld" \
    AR="${SYSROOT_DIR}/bin/llvm-ar" \
    NM="${SYSROOT_DIR}/bin/llvm-nm" \
    STRIP="${SYSROOT_DIR}/bin/llvm-strip" \
    OBJCOPY="${SYSROOT_DIR}/bin/llvm-objcopy" \
    OBJDUMP="${SYSROOT_DIR}/bin/llvm-objdump" \
    READELF="${SYSROOT_DIR}/bin/llvm-readelf" \
    HOSTCC="${SYSROOT_DIR}/bin/clang" \
    HOSTCXX="${SYSROOT_DIR}/bin/clang++" \
    HOSTAR="${SYSROOT_DIR}/bin/llvm-ar" \
    HOSTLD="${SYSROOT_DIR}/bin/ld.lld" \
    HOSTCFLAGS="-Wno-error -Wno-everything -isystem ${SRC_DIR}/linux/arch/x86/include/asm -isystem ${SRC_DIR}/linux/arch/x86/include -isystem ${SRC_DIR}/linux/scripts/include -isystem ${SRC_DIR}/linux/include -isystem ${SYSROOT_DIR}/include -isystem ${SYSROOT_DIR}/usr/include -isystem ${SYSROOT_DIR}/include/x86_64-unknown-linux-llvm -isystem ${SYSROOT_DIR}/lib/clang/21/include -isystem ${SYSROOT_DIR}/linux/tools/include/ " \
    HOSTLDFLAGS="-static -L${SYSROOT_DIR}/lib -Wl,-rpath-link,${SYSROOT_DIR}/lib -L${COMPAT_DIR} -lcompat" \
    LDFLAGS="-static -L${SYSROOT_DIR}/lib -L${COMPAT_DIR} -lcompat" \
    KCONFIG_ALLCONFIG=/dev/stdin \
    tinyconfig

# Now build the kernel with the configured options
make O="${KERNEL_BUILD_DIR}" \
    ARCH=x86_64 \
    LLVM=1 \
    LLVM_IAS=1 \
    -j"${JOBS}" \
    CC="${SYSROOT_DIR}/bin/clang" \
    LD="${SYSROOT_DIR}/bin/ld.lld" \
    AR="${SYSROOT_DIR}/bin/llvm-ar" \
    NM="${SYSROOT_DIR}/bin/llvm-nm" \
    STRIP="${SYSROOT_DIR}/bin/llvm-strip" \
    OBJCOPY="${SYSROOT_DIR}/bin/llvm-objcopy" \
    OBJDUMP="${SYSROOT_DIR}/bin/llvm-objdump" \
    READELF="${SYSROOT_DIR}/bin/llvm-readelf" \
    HOSTCC="${SYSROOT_DIR}/bin/clang" \
    HOSTCXX="${SYSROOT_DIR}/bin/clang++" \
    HOSTAR="${SYSROOT_DIR}/bin/llvm-ar" \
    HOSTLD="${SYSROOT_DIR}/bin/ld.lld" \
    HOSTCFLAGS="-Wno-error -Wno-everything -isystem ${SRC_DIR}/linux/scripts/include -isystem ${SRC_DIR}/linux/include -isystem ${SYSROOT_DIR}/include -isystem ${SYSROOT_DIR}/usr/include -isystem ${SYSROOT_DIR}/include/x86_64-unknown-linux-llvm -isystem ${SYSROOT_DIR}/lib/clang/21/include -isystem ${SYSROOT_DIR}/linux/tools/include/ " \
    HOSTLDFLAGS="-static -L${SYSROOT_DIR}/lib -Wl,-rpath-link,${SYSROOT_DIR}/lib -L${COMPAT_DIR} -lcompat" \
    LDFLAGS="-static -L${SYSROOT_DIR}/lib -L${COMPAT_DIR} -lcompat" \
    all

echo "Kernel build completed. The kernel image is at: ${KERNEL_BUILD_DIR}/arch/x86/boot/bzImage"