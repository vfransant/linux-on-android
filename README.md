# linux-on-android
Automatizated script to install ubuntu on your android device, no root needed.

![Screenshot_20240924_233802_AVNC.jpg](https://raw.githubusercontent.com/vfransant/linux-on-android/refs/heads/main/Screenshot_20240924_233802_AVNC.jpg)

# Features
- Installs Ubuntu 24.04 Arm64
- XFCE enviroment fully working
- Firefox pre-installed

# Other repositories used
- [proot-distro](https://github.com/termux/proot-distro)
- [Termux-Proot-Custom-Installer](https://github.com/23xvx/Termux-Proot-Custom-Installer)

# Requirements
- [Termux](https://termux.dev/en/), preferably latest version - and not from Play Store (no more updates from there)
- The installation takes about 3.2GB of space
- VNC Viewer app of your choise
  - My suggestion, if you are using a physical keyboard and mouse:
      - [AVNC](https://play.google.com/store/apps/details?id=com.gaurav.avnc)
  - My suggestion, if relying only on phones touch screen and on-screen keyboard:
      - [RealVNC Viewer: Remote Desktop](https://play.google.com/store/apps/details?id=com.realvnc.viewer.android)

# Installation
Using `curl`

```
curl -O https://raw.githubusercontent.com/vfransant/linux-on-android/refs/heads/main/ubuntu-24_04-instalation.sh && bash ubuntu-24_04-instalation.sh
```

Using `wget`
```
wget https://raw.githubusercontent.com/vfransant/linux-on-android/refs/heads/main/ubuntu-24_04-instalation.sh && bash ubuntu-24_04-instalation.sh
```
# How to use?
After running the script, you can start your ubuntu by opening your Termux and running
```dash ubuntu.sh```
Then, type
```vncserver```
and it will start a vnc session. Use your VNC Viewer of choice and connect either to
- If you want to see your screen on the device you are using
```127.0.0.1:1``` or ```localhost:1```
- If you want to use it on another device
your device's IP on your local network, followed by :1
Example: `192.168.0.15:1`

The default password is `linux`
