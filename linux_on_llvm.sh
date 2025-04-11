#!/bin/bash
# Script to build Linux kernel and BusyBox using only LLVM toolchain (clang)
# Minimal configuration for QEMU with initramfs and extra debugging

# Configuration
SCRIPT_DIR="${HOME}/x86_64-linux-llvm"
SRC_DIR="${HOME}/src"
BUILD_DIR="${HOME}/build"
SYSROOT_DIR="${HOME}/sysroot"
NUM_CORES=$(nproc)
KERNEL_DIR="${SRC_DIR}/linux"
export ARCH=x86_64

NO_WARNINGS_SUS=" -Wno-address-of-packed-member -Wno-int-in-bool-context  -Wno-format-truncation -Wno-self-assign -Wno-string-plus-int -Wno-shift-sign-overflow -Wno-string-conversion -Wno-class-varargs -Wno-array-bounds-pointer-arithmetic -Wno-alloca -Wno-bitfield-enum-conversion -Wno-anon-enum-enum-conversion -Wno-format-nonliteral -Wno-assign-enum -Wno-missing-variable-declarations -Wno-conditional-uninitialized -Wno-format-non-iso -Wno-format -Wno-switch-enum -Wno-bad-function-cast -Wno-tautological-value-range-compare -Wno-duplicate-enum -Wno-implicit-int-conversion -Wno-switch-default  -Wno-cast-align -Wno-cast-qual -Wno-sign-conversion -Wno-shorten-64-to-32 -Wno-sign-compare "
NO_WARNINGS_COOL=" -Wno-implicit-int-float-conversion -Wno-misleading-indentation -Wno-float-conversion -Wno-cast-function-type-strict  -Wno-double-promotion  -Wno-unused-command-line-argument -Wno-unused-result -Wno-unused-variable -Wno-unused-function -Wno-missing-prototypes -Wno-missing-include-dirs -Wno-missing-field-initializers -Wno-undef -Wno-implicit-fallthrough -Wno-unreachable-code-break -Wno-unused-macros -Wno-comma -Wno-extra-semi-stmt  -Wno-compound-token-split-by-space -Wno-shadow -Wno-unreachable-code-return -Wno-unused-parameter -Wno-unreachable-code -Wno-covered-switch-default -Wno-redundant-parens -Wno-declaration-after-statement  -Wno-used-but-marked-unused -Wno-packed -Wno-c++98-compat -Wno-c2y-extensions -Wno-pedantic -Wno-pre-c11-compat -Wno-language-extension-token -Wno-c++-compat -Wno-disabled-macro-expansion -Wno-keyword-macro -Wno-c23-compat -Wno-variadic-macros -Wno-reserved-macro-identifier -Wno-unsafe-buffer-usage  -Wno-padded -Wno-missing-noreturn -Wno-gnu-conditional-omitted-operand -Wno-documentation -Wno-documentation-unknown-command -Wno-reserved-identifier "
NO_WARNINGS=" -Wno-error -Weverything ${NO_WARNINGS_COOL} ${NO_WARNINGS_SUS}   "

# Define LLVM toolchain variables
HOST_CC="clang-21"
HOST_LD="ld.lld-21"
HOST_AR="llvm-ar-21"
HOST_NM="llvm-nm-21"
HOST_STRIP="llvm-strip-21"
HOST_OBJCOPY="llvm-objcopy-21"
HOST_OBJDUMP="llvm-objdump-21"
HOST_READELF="llvm-readelf-21"

TARGET_CC="${SYSROOT_DIR}/bin/clang"
TARGET_LD="${SYSROOT_DIR}/bin/ld.lld"
TARGET_AR="${SYSROOT_DIR}/bin/llvm-ar"
TARGET_NM="${SYSROOT_DIR}/bin/llvm-nm"
TARGET_STRIP="${SYSROOT_DIR}/bin/llvm-strip"
TARGET_OBJCOPY="${SYSROOT_DIR}/bin/llvm-objcopy"
TARGET_OBJDUMP="${SYSROOT_DIR}/bin/llvm-objdump"
TARGET_READELF="${SYSROOT_DIR}/bin/llvm-readelf"


CFLAGS_KERNEL=" ${NO_WARNINGS} -O3  "

mkdir -p "${BUILD_DIR}"
mkdir -p "${SRC_DIR}"

echo "Building the kernel..."

if [ ! -d "${KERNEL_DIR}" ]; then
    git clone --depth=1 https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git "${KERNEL_DIR}"
fi

cd "${KERNEL_DIR}"

# Clean any previous build artifacts
make mrproper

# Make base KVM guest config
make -j${NUM_CORES} LLVM=1 \
    CC=${TARGET_CC} \
    LD=${TARGET_LD} \
    AR=${TARGET_AR} \
    NM=${TARGET_NM} \
    STRIP=${TARGET_STRIP} \
    OBJCOPY=${TARGET_OBJCOPY} \
    OBJDUMP=${TARGET_OBJDUMP} \
    READELF=${TARGET_READELF} \
    HOSTCC=${HOST_CC} \
    HOSTCXX=${HOST_CXX} \
    HOSTAR=${HOST_AR} \
    HOSTLD=${HOST_LD} \
    LLVM_IAS=1 \
    HOSTCFLAGS=" ${NO_WARNINGS} " \
    HOSTLDFLAGS="" \
    KBUILD_HOSTLDFLAGS="" \
    CFLAGS_KERNEL="${CFLAGS_KERNEL}" \
    CROSS_COMPILE="" \
    LDFLAGS_vmlinux=" -z max-page-size=0x200000  " \
    kvm_guest.config

# Enable debugging options in the kernel config
echo "Enabling kernel debugging options..."
cat >> .config << EOF
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_INFO=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
CONFIG_PRINTK_TIME=y
CONFIG_DYNAMIC_DEBUG=y
CONFIG_PANIC_ON_OOPS=n
CONFIG_PANIC_TIMEOUT=-1
CONFIG_BOOT_PRINTK_DELAY=y
CONFIG_DEBUG_FS=y
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_KGDB=y
CONFIG_KGDB_SERIAL_CONSOLE=y
CONFIG_DEBUG_RODATA=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_FRAME_POINTER=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=65536
CONFIG_RD_GZIP=y
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_MODULE_COMPRESS=y
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
CONFIG_MCORE2=y
CONFIG_X86_INTEL_PSTATE=y
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_SCHED_MC=y
CONFIG_SCHED_SMT=y
CONFIG_NUMA_BALANCING=y
CONFIG_MQ_IOCTL=y
CONFIG_BLK_WBT=y
CONFIG_BLK_WBT_MQ=y
CONFIG_SLUB=y
CONFIG_SLUB_CPU_PARTIAL=y
CONFIG_DEBUG_KERNEL=n
CONFIG_DEBUG_INFO=n
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
EOF

# Update the config
make olddefconfig

# Build the kernel (bzImage) with LLVM
make -j${NUM_CORES} LLVM=1 \
    CC=${TARGET_CC} \
    LD=${TARGET_LD} \
    AR=${TARGET_AR} \
    NM=${TARGET_NM} \
    STRIP=${TARGET_STRIP} \
    OBJCOPY=${TARGET_OBJCOPY} \
    OBJDUMP=${TARGET_OBJDUMP} \
    READELF=${TARGET_READELF} \
    HOSTCC=${HOST_CC} \
    HOSTCXX=${HOST_CXX} \
    HOSTAR=${HOST_AR} \
    HOSTLD=${HOST_LD} \
    LLVM_IAS=1 \
    HOSTCFLAGS=" ${NO_WARNINGS}  " \
    HOSTLDFLAGS="" \
    KBUILD_HOSTLDFLAGS="" \
    CFLAGS_KERNEL="${CFLAGS_KERNEL}" \
    CROSS_COMPILE="" \
    LDFLAGS_vmlinux=" -z max-page-size=0x200000 " \
    bzImage

# Print kernel size
echo "Kernel size:"
ls -lh arch/x86/boot/bzImage


# BusyBox setup
INITRAMFS_DIR="${BUILD_DIR}/initramfs"
BUSYBOX_DIR="${BUILD_DIR}/busybox-git"
BUSYBOX_GIT="https://git.busybox.net/busybox"

# Create build directories
mkdir -p "${INITRAMFS_DIR}"

# Download and build BusyBox from Git
echo "Building BusyBox..."
cd "${BUILD_DIR}"

# Clone BusyBox Git repository
if [ ! -d "busybox-git" ]; then
    git clone "${BUSYBOX_GIT}" busybox-git
fi

# Configure and build BusyBox statically with LLVM toolchain
cd "${BUSYBOX_DIR}"
make distclean
make -j${NUM_CORES} \
  CC=${TARGET_CC} \
  LD=${TARGET_LD} \
  AR=${TARGET_AR} \
  NM=${TARGET_NM} \
  STRIP=${TARGET_STRIP} \
  OBJCOPY=${TARGET_OBJCOPY} \
  OBJDUMP=${TARGET_OBJDUMP} \
  READELF=${TARGET_READELF} \
  HOSTCC=${HOST_CC} \
  HOSTCXX=${HOST_CXX} \
  HOSTAR=${HOST_AR} \
  HOSTLD=${HOST_LD} \
  STRIP=${LLVM_STRIP} \
  OBJCOPY=${LLVM_OBJCOPY} \
  OBJDUMP=${LLVM_OBJDUMP} \
  CFLAGS=" --rtlib=compiler-rt -unwind=libunwind ${NO_WARNINGS} " \
  defconfig

# Configure BusyBox for static build
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
sed -i 's/CONFIG_TC=y/CONFIG_TC=n/' .config

# Build with the same LLVM toolchain as the kernel
make -j${NUM_CORES} \
    CC=${LLVM_CC} \
    HOSTCC=${LLVM_CC} \
    LD=${LLVM_LD} \
    AR=${LLVM_AR} \
    NM=${LLVM_NM} \
    STRIP=${LLVM_STRIP} \
    OBJCOPY=${LLVM_OBJCOPY} \
    OBJDUMP=${LLVM_OBJDUMP} \
    CFLAGS=" --rtlib=compiler-rt -unwind=libunwind ${NO_WARNINGS} "

make install CONFIG_PREFIX="${INITRAMFS_DIR}"

# Create initramfs
echo "Creating initramfs..."

# Create additional directory structure
cd "${INITRAMFS_DIR}"
mkdir -p {proc,sys,dev,tmp,root}

# Create init script
cat > init << 'EOF'
#!/bin/sh

# Mount essential filesystems
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev || mknod -m 0666 /dev/null c 1 3

# Print success message
echo "*************************************"
echo "*                                   *"
echo "* Minimal initramfs boot successful *"
echo "*                                   *"
echo "*************************************"

# Display kernel log
dmesg | tail

# Drop to a shell
exec /bin/sh
EOF

# Make init executable
chmod +x init

# Create the initramfs cpio archive
cd "${INITRAMFS_DIR}"
find . -print0 | cpio --null -ov --format=newc | gzip -9 > "${BUILD_DIR}/initramfs.cpio.gz"

echo "Initramfs created at: ${BUILD_DIR}/initramfs.cpio.gz"
echo
echo "You can now boot your kernel with QEMU using:"
echo "qemu-system-x86_64 -kernel ${KERNEL_DIR}/arch/x86/boot/bzImage -initrd ${BUILD_DIR}/initramfs.cpio.gz -append \"console=ttyS0 earlyprintk=serial,ttyS0,115200 debug loglevel=7 root=/dev/ram0 rdinit=/init\" -nographic"