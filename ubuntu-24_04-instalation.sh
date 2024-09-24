#!/data/data/com.termux/files/usr/bin/bash

ROOTFS_LINK="https://cloud-images.ubuntu.com/releases/24.04/release-20240911/ubuntu-24.04-server-cloudimg-arm64-root.tar.xz"
DISTRO_NAME="ubuntu"

termux-change-repo

# Updating Termux repo
pkg update

# Installing updates
pkg upgrade

# Setting up Termux access to Android storage (downloads, photos, etc.)
termux-setup-storage

# Download and run the wget-proot.sh script to install the distro
curl https://raw.githubusercontent.com/23xvx/Termux-Proot-Custom-Installer/main/wget-proot.sh >> wget-proot.sh
bash wget-proot.sh

# When prompted, input the rootfs link and the distro name:
# ROOTFS_LINK="https://cloud-images.ubuntu.com/releases/24.04/release-20240911/ubuntu-24.04-server-cloudimg-arm64-root.tar.xz"
# DISTRO_NAME="ubuntu"

# Here we are using a here document to feed the input directly
{
    echo "$ROOTFS_LINK"
    echo "$DISTRO_NAME"
} | bash wget-proot.sh

# After this, installation will continue, but there will be errors.
# Now let's manually fix these errors by editing the ubuntu.sh script.
# We will overwrite the content of ubuntu.sh with the correct code:

cat << 'EOF' > ubuntu.sh
#!/data/data/com.termux/files/usr/bin/bash
cd $(dirname $0)

# Start PulseAudio
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"

# Set login shell for the distribution
login_shell=$(grep "^root:" "u-fs/etc/passwd" | cut -d ':' -f 7)

# Unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD

# Proot configured command
command="proot"
# Uncomment the following line if you get "FATAL: kernel too old" message.
# command="$command -k 4.14.81"
command="$command --link2symlink"
command="$command -0"
command="$command -b ubuntu-fs"
command="$command -b /dev"
command="$command -b /dev/null:/proc/sys/kernel/cap_last_cap"
command="$command -b /dev/null:/proc/stat"
command="$command -b /dev/urandom:/dev/random"
command="$command -b /proc"
command="$command -b /proc/self/fd:/dev/fd"
command="$command -b /proc/self/fd/0:/dev/stdin"
command="$command -b /proc/self/fd/1:/dev/stdout"
command="$command -b /proc/self/fd/2:/dev/stderr"
command="$command -b /sys"
command="$command -b /data/data/com.termux/files/usr/tmp:/tmp"
command="$command -b u-fs/tmp:/dev/shm"
command="$command -b /data/data/com.termux"
command="$command -b /sdcard"
command="$command -b /mnt"
command="$command -w /root"

# Conditional to select login shell
if [ -n "$login_shell" ]; then
    command="$command /usr/bin/env -i"
    command="$command HOME=/root"
    command="$command PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
    command="$command TERM=xterm-256color"
    command="$command LANG=C.UTF-8"
    command="$command $login_shell"
else
    command="$command /usr/bin/env -i"
    command="$command HOME=/root"
    command="$command PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
    command="$command TERM=xterm-256color"
    command="$command LANG=C.UTF-8"
    command="$command /bin/bash"
fi

# Execute the command
exec $command
EOF

# Run the updated script:
dash ubuntu.sh

# Now, update and install XFCE, VNC, and dbus:
echo "y" | sudo apt update
echo "y" | sudo apt upgrade -y
echo "y" | sudo apt install xfce4 xfce4-session xfce4-goodies tigervnc-standalone-server dbus-x11 -y

# Set up the VNC password automatically (set to "linux"):
echo -e "linux\nlinux\nn" | vncserver

# Now, edit the VNC startup configuration file:
cat << 'EOF' > ~/.vnc/xstartup
#!/bin/sh
xrdb $HOME/.Xresources
dbus-launch --exit-with-session &
startxfce4
EOF

# Give execution permission to the file:
chmod +x ~/.vnc/xstartup

# Export the USER variable and add it to bashrc:
export USER=root
echo "export USER=root" >> ~/.bashrc

# Export the DISPLAY variable for VNC:
export DISPLAY=:1

# Set up the XDG_RUNTIME_DIR:
export XDG_RUNTIME_DIR=/tmp/runtime-root

# Create the .Xauthority file if it doesn't exist:
touch ~/.Xauthority

# Install Xserver as a precaution:
echo "y" | sudo apt install x11-xserver-utils -y

# Restart the VNC server to apply changes:
vncserver -kill :1
vncserver

# Now, let's install Firefox-ESR:
# Script to download and install Firefox-ESR:

# URL to fetch the .deb package of Firefox
DOWNLOAD_URL=$(wget -q -O - https://packages.debian.org/sid/arm64/firefox-esr/download | grep 'ftp.us' | grep 'esr-1_arm64' | grep -oP '(?<=href=")[^"]*')

# Check if the link was found
if [ -z "$DOWNLOAD_URL" ]; then
    echo "Error: file link not found."
    exit 1
fi

# Download the .deb file
echo "Downloading the file: $DOWNLOAD_URL"
wget -P ~/Downloads "$DOWNLOAD_URL"

# Install the .deb package
echo "Installing the package..."
sudo dpkg -i ~/Downloads/$(basename "$DOWNLOAD_URL")

# Fix dependencies if needed
echo "Fixing dependencies..."
echo "y" | sudo apt-get install -f -y

# Add configuration for Firefox in ~/.bashrc
echo "export MOZ_DISABLE_CONTENT_SANDBOX=1" >> ~/.bashrc

# Reload the new configuration:
source ~/.bashrc

# Firefox should now be installed and configured.
