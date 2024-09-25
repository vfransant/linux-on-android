#!/data/data/com.termux/files/usr/bin/bash

# Define rootfs link and distro name
ROOTFS_LINK="https://cloud-images.ubuntu.com/releases/24.04/release-20240911/ubuntu-24.04-server-cloudimg-arm64-root.tar.xz"
DISTRO_NAME="ubuntu"

# Change Termux repo
termux-change-repo

# Updating Termux repo
pkg update

# Install nano
pkg install nano

# Installing updates
pkg upgrade

# Setting up Termux access to Android storage (downloads, photos, etc.)
termux-setup-storage

# Download and prepare the wget-proot.sh script
curl -O https://raw.githubusercontent.com/23xvx/Termux-Proot-Custom-Installer/main/wget-proot.sh
chmod +x wget-proot.sh

# Copy the script and apply the necessary modifications using sed
cp wget-proot.sh wget-proot-modified.sh
sed -i "s|read URL|URL=${ROOTFS_LINK}|" wget-proot-modified.sh
sed -i "s|read ds_name|ds_name=${DISTRO_NAME}|" wget-proot-modified.sh

# Run the modified script with no user interaction
bash wget-proot-modified.sh

###################################################################

# Run the updated script
bash ubuntu.sh

# Now, update and install XFCE, VNC, and dbus
echo "y" | sudo apt update
echo "y" | sudo apt upgrade -y
echo "y" | sudo apt install xfce4 xfce4-session xfce4-goodies tigervnc-standalone-server dbus-x11 -y

# Set up the VNC password automatically (set to "linux")
echo -e "linux\nlinux\nn" | vncserver

# Now, edit the VNC startup configuration file
cat << 'EOF' > ~/.vnc/xstartup
#!/bin/sh
xrdb $HOME/.Xresources
dbus-launch --exit-with-session &
startxfce4
EOF

# Give execution permission to the file
chmod +x ~/.vnc/xstartup

# Export the USER variable and add it to bashrc
export USER=root
echo "export USER=root" >> ~/.bashrc

# Export the DISPLAY variable for VNC
export DISPLAY=:1

# Set up the XDG_RUNTIME_DIR
export XDG_RUNTIME_DIR=/tmp/runtime-root

# Create the .Xauthority file if it doesn't exist
touch ~/.Xauthority

# Install Xserver as a precaution
echo "y" | sudo apt install x11-xserver-utils -y

# Restart the VNC server to apply changes
vncserver -kill :1
vncserver

# Now, let's install Firefox-ESR
# Script to download and install Firefox-ESR

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

# Reload the new configuration
source ~/.bashrc

# Firefox should now be installed and configured
