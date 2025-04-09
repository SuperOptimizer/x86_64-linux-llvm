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
