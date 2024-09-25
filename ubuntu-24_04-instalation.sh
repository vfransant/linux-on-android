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

# Remove the line that enters the Ubuntu environment
# bash ubuntu.sh  # REMOVED

# Replace with commands passed directly to Ubuntu
bash ubuntu.sh "apt update -y && apt upgrade -y && apt install xfce4 xfce4-session xfce4-goodies tigervnc-standalone-server dbus-x11 -y && echo -e 'linux\nlinux\nn' | vncserver"

# Edit the VNC startup configuration file inside the Ubuntu environment
bash ubuntu.sh "cat << 'EOF' > ~/.vnc/xstartup
#!/bin/sh
xrdb \$HOME/.Xresources
dbus-launch --exit-with-session &
startxfce4
EOF
chmod +x ~/.vnc/xstartup"

# Export environment variables and configure VNC inside Ubuntu
bash ubuntu.sh "export USER=root && echo 'export USER=root' >> ~/.bashrc && export DISPLAY=:1 && export XDG_RUNTIME_DIR=/tmp/runtime-root && touch ~/.Xauthority"

# Install Xserver as a precaution
bash ubuntu.sh "apt install x11-xserver-utils -y"

# Restart the VNC server to apply changes
bash ubuntu.sh "vncserver -kill :1 && vncserver"

# Download and install Firefox-ESR
bash ubuntu.sh "
DOWNLOAD_URL=\$(wget -q -O - https://packages.debian.org/sid/arm64/firefox-esr/download | grep 'ftp.us' | grep 'esr-1_arm64' | grep -oP '(?<=href=\")[^\"*]')
if [ -z \"\$DOWNLOAD_URL\" ]; then
    echo 'Error: file link not found.'
    exit 1
fi
echo 'Downloading the file: \$DOWNLOAD_URL'
wget -P ~/Downloads \"\$DOWNLOAD_URL\"
dpkg -i ~/Downloads/\$(basename \"\$DOWNLOAD_URL\")
apt-get install -f -y"

# Add Firefox configuration to .bashrc
bash ubuntu.sh "echo 'export MOZ_DISABLE_CONTENT_SANDBOX=1' >> ~/.bashrc && source ~/.bashrc"
