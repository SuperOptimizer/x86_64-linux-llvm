# Mount proc, sys, and dev
sudo mount -t proc none /ubuntu/proc
sudo mount -t sysfs none /ubuntu/sys
sudo mount -o bind /dev /ubuntu/dev
sudo mount -o bind /dev/pts /ubuntu/dev/pts

# Copy DNS configuration
sudo cp /etc/resolv.conf /ubuntu/etc/resolv.conf

sudo chroot /ubuntu /bin/bash