#!/bin/bash
# Script to build Linux kernel and BusyBox using only LLVM toolchain (clang)
# Minimal configuration for QEMU with initramfs and extra debugging

# Configuration
SCRIPT_DIR="${HOME}/x86_64-linux-llvm"
SRC_DIR="${HOME}/src"
BUILD_DIR="${HOME}/build"
INSTALL_DIR="${HOME}/sysroot"
NUM_CORES=$(nproc)
KERNEL_DIR="${SRC_DIR}/linux"
export ARCH=x86_64

NO_WARNINGS_SUS=" -Wno-address-of-packed-member -Wno-int-in-bool-context  -Wno-format-truncation -Wno-self-assign -Wno-string-plus-int -Wno-shift-sign-overflow -Wno-string-conversion -Wno-class-varargs -Wno-array-bounds-pointer-arithmetic -Wno-alloca -Wno-bitfield-enum-conversion -Wno-anon-enum-enum-conversion -Wno-format-nonliteral -Wno-assign-enum -Wno-missing-variable-declarations -Wno-conditional-uninitialized -Wno-format-non-iso -Wno-format -Wno-switch-enum -Wno-bad-function-cast -Wno-tautological-value-range-compare -Wno-duplicate-enum -Wno-implicit-int-conversion -Wno-switch-default  -Wno-cast-align -Wno-cast-qual -Wno-sign-conversion -Wno-shorten-64-to-32 -Wno-sign-compare "
NO_WARNINGS_COOL=" -Wno-implicit-int-float-conversion -Wno-misleading-indentation -Wno-float-conversion -Wno-cast-function-type-strict  -Wno-double-promotion  -Wno-unused-command-line-argument -Wno-unused-result -Wno-unused-variable -Wno-unused-function -Wno-missing-prototypes -Wno-missing-include-dirs -Wno-missing-field-initializers -Wno-undef -Wno-implicit-fallthrough -Wno-unreachable-code-break -Wno-unused-macros -Wno-comma -Wno-extra-semi-stmt  -Wno-compound-token-split-by-space -Wno-shadow -Wno-unreachable-code-return -Wno-unused-parameter -Wno-unreachable-code -Wno-covered-switch-default -Wno-redundant-parens -Wno-declaration-after-statement  -Wno-used-but-marked-unused -Wno-packed -Wno-c++98-compat -Wno-c2y-extensions -Wno-pedantic -Wno-pre-c11-compat -Wno-language-extension-token -Wno-c++-compat -Wno-disabled-macro-expansion -Wno-keyword-macro -Wno-c23-compat -Wno-variadic-macros -Wno-reserved-macro-identifier -Wno-unsafe-buffer-usage  -Wno-padded -Wno-missing-noreturn -Wno-gnu-conditional-omitted-operand -Wno-documentation -Wno-documentation-unknown-command -Wno-reserved-identifier "
NO_WARNINGS=" -Wno-error -Weverything ${NO_WARNINGS_COOL} ${NO_WARNINGS_SUS}   "

# Define LLVM toolchain variables
LLVM_CC="clang-21"
LLVM_LD="ld.lld-21"
LLVM_AR="llvm-ar-21"
LLVM_NM="llvm-nm-21"
LLVM_STRIP="llvm-strip-21"
LLVM_OBJCOPY="llvm-objcopy-21"
LLVM_OBJDUMP="llvm-objdump-21"
LLVM_READELF="llvm-readelf-21"

mkdir -p "${BUILD_DIR}"
mkdir -p "${SRC_DIR}"
mkdir -p "${INSTALL_DIR}"

echo "Building the kernel..."

if [ ! -d "${KERNEL_DIR}" ]; then
    git clone --depth=1 https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git "${KERNEL_DIR}"
fi

cd "${KERNEL_DIR}"

# Clean any previous build artifacts
make mrproper

# Make base KVM guest config
make -j${NUM_CORES} LLVM=1 \
    CC=${LLVM_CC} \
    LD=${LLVM_LD} \
    AR=${LLVM_AR} \
    NM=${LLVM_NM} \
    STRIP=${LLVM_STRIP} \
    OBJCOPY=${LLVM_OBJCOPY} \
    OBJDUMP=${LLVM_OBJDUMP} \
    READELF=${LLVM_READELF} \
    HOSTCC=${LLVM_CC} \
    HOSTCXX="clang++-21" \
    HOSTAR=${LLVM_AR} \
    HOSTLD=${LLVM_LD} \
    HOSTCFLAGS=" ${NO_WARNINGS} " \
    HOSTLDFLAGS="" \
    KBUILD_HOSTLDFLAGS="" \
    CFLAGS_KERNEL=" ${NO_WARNINGS}   " \
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
EOF

# Update the config
make olddefconfig

# Build the kernel (bzImage) with LLVM
make -j${NUM_CORES} LLVM=1 \
    CC=${LLVM_CC} \
    LD=${LLVM_LD} \
    AR=${LLVM_AR} \
    NM=${LLVM_NM} \
    STRIP=${LLVM_STRIP} \
    OBJCOPY=${LLVM_OBJCOPY} \
    OBJDUMP=${LLVM_OBJDUMP} \
    READELF=${LLVM_READELF} \
    HOSTCC=${LLVM_CC} \
    HOSTCXX="clang++-21" \
    HOSTAR=${LLVM_AR} \
    HOSTLD=${LLVM_LD} \
    HOSTCFLAGS=" ${NO_WARNINGS}  " \
    HOSTLDFLAGS="" \
    KBUILD_HOSTLDFLAGS="" \
    CFLAGS_KERNEL="  ${NO_WARNINGS}  " \
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
         CC=${LLVM_CC} \
         HOSTCC=${LLVM_CC} \
         LD=${LLVM_LD} \
         AR=${LLVM_AR} \
         NM=${LLVM_NM} \
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