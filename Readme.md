# Android Pentesting Setup (Anoy) beta

This script automates the setup process for Android pentesting on Debian-based (Ubuntu, Kali, etc.), Arch-based Linux systems, and Windows.

## Features
- Installs required dependencies for Android pentesting
- Supports multiple operating systems
- Downloads and sets up Frida for dynamic analysis
- Installs Android Studio (Prefer in window do manually)
- Assists with SSL pinning bypass using Frida

## Prerequisites
- ADB installed on your system
- Android device or emulator running with root access
- Python installed

## Installation & Setup
### Linux (Debian-based & Arch-based)
```bash
chmod +x setup_android_pentest.py
./setup_android_pentest.py
```

### Windows
```powershell
python setup_android_pentest.py
```

## Usage
1. The script will detect your OS and install dependencies accordingly.
2. It will prompt you to confirm if an Android emulator is running.
3. It will ensure ADB root mode is enabled (you need to run `adb root` manually when prompted).
4. It will set SELinux to permissive mode.
5. It will download and install the appropriate Frida version based on your device architecture.
6. It will ask if you want to proceed with Frida injection.
   - If confirmed, it will attempt to fetch the APK package name automatically.
   - If not found, you will be asked to enter it manually.
   - It will then run Frida with SSL pinning bypass.

## Manual Commands You May Need to Run
Before executing the script, ensure that:
```bash
adb root
```
After running the script, use Frida commands like:
```bash
frida-ps -Uai
frida -U -f com.target.app -l ./ssl_pinning.js
```

## Notes
- Ensure `ssl_pinning.js` is in the same directory as the script.
- This script assumes you have root access on your Android device/emulator.
- On Windows, install required dependencies manually if needed.

## Medium 

 1.  **[Artcle - 1](https://medoum.com)**
 2.  **[Artcle - 2](https://medoum.com)**
 3.  **[Artcle - 3](https://medoum.com)**
 4.  **[Artcle - 4](https://medoum.com)**
 5.  **[Artcle - 5](https://medoum.com)**

## Disclaimer
This tool is intended for educational and ethical hacking purposes only. Do not use it on systems you do not own or have explicit permission to test.

