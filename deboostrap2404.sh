# Install debootstrap if not already installed
sudo apt-get update
sudo apt-get install -y debootstrap

# Create a directory for the chroot
sudo mkdir -p /path/to/ubuntu-chroot

# Run debootstrap for Ubuntu 24.04 (Noble Numbat)
sudo debootstrap --arch=amd64 noble /ubuntu http://archive.ubuntu.com/ubuntu/