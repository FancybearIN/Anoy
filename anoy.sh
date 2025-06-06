#!/bin/bash

set -e  # Exit on error

# Display author name
echo "Android Pentesting Setup by FancyBearIN"

# Detect OS
if [[ -f /etc/os-release ]]; then
    . /etc/os-release  # Source the file to get OS variables

    if [[ "$ID" == "arch" || "$ID_LIKE" == "arch" ]]; then
        OS="Arch"
    elif [[ "$ID" == "debian" || "$ID_LIKE" =~ "debian" ]]; then
        OS="Debian"
    else
        echo "Unsupported Linux distribution: $ID. Exiting."
        exit 1
    fi
else
    echo "/etc/os-release not found. Unable to detect OS. Exiting."
    exit 1
fi

echo "Detected OS: $OS"


echo "This script will install the following dependencies:"
echo "- Python & pip"
echo "- ADB (Android Debug Bridge)"
echo "- Frida (for dynamic analysis)"
echo "- Objection (for runtime security testing)"
echo "- Android Studio"
echo "- Required libraries for your OS"

read -p "Do you want to proceed with the installation? (yes/no): " proceed
if [[ "$proceed" != "yes" ]]; then
    echo "Installation aborted."
    exit 0
fi

# Install dependencies
if [[ "$OS" == "Debian" ]]; then
    sudo apt update && sudo apt install -y python3 python3-pip adb unzip wget
elif [[ "$OS" == "Arch" ]]; then
    sudo pacman -Syu --noconfirm python python-pip android-tools unzip wget
fi

# Install Android Studio
if [[ "$OS" == "Debian" ]]; then
    echo "Checking if Android Studio is already installed..."
    if command -v android-studio &> /dev/null; then
        echo "Android Studio is already installed. Skipping installation."
    else
        echo "Installing Android Studio using snap..."
        if ! command -v snap &> /dev/null; then
            echo "snapd is not installed. Installing snapd..."
            sudo apt update && sudo apt install -y snapd
            sudo systemctl enable --now snapd
            sudo ln -s /var/lib/snapd/snap /snap
        fi

        # Verify snapd is running
        if ! systemctl is-active --quiet snapd; then
            echo "Error: snapd service is not running. Please start it using 'sudo systemctl start snapd'."
            exit 1
        fi

        # Install Android Studio
        sudo snap install android-studio --classic || {
            echo "Error: Failed to install Android Studio via snap. Please check your snapd setup."
            exit 1
        }
        echo "Android Studio installed successfully."
    fi
elif [[ "$OS" == "Arch" ]]; then
    echo "Checking if Android Studio is already installed..."
    if command -v android-studio &> /dev/null; then
        echo "Android Studio is already installed. Skipping installation."
    else
        echo "Installing Android Studio using pacman..."
        sudo pacman -S --noconfirm android-studio || {
            echo "Error: Failed to install Android Studio via pacman. Please check your package manager setup."
            exit 1
        }
        echo "Android Studio installed successfully."
    fi
fi
# Install Android Studio
if [[ "$OS" == "Debian" ]]; then
    echo "Checking if Android Studio is already installed..."
    if command -v android-studio &> /dev/null; then
        echo "Android Studio is already installed. Skipping installation."
    else
        echo "Installing Android Studio using snap..."
        if ! command -v snap &> /dev/null; then
            echo "snapd is not installed. Installing snapd..."
            sudo apt update && sudo apt install -y snapd
            sudo systemctl enable --now snapd
            sudo ln -s /var/lib/snapd/snap /snap
        fi

        # Verify snapd is running
        if ! systemctl is-active --quiet snapd; then
            echo "Error: snapd service is not running. Please start it using 'sudo systemctl start snapd'."
            exit 1
        fi

        # Install Android Studio
        sudo snap install android-studio --classic
        echo "Android Studio installed successfully."
    fi
elif [[ "$OS" == "Arch" ]]; then
    echo "Checking if Android Studio is already installed..."
    if command -v android-studio &> /dev/null; then
        echo "Android Studio is already installed. Skipping installation."
    else
        echo "Installing Android Studio using pacman..."
        sudo pacman -S --noconfirm android-studio || {
            echo "Error: Failed to install Android Studio via pacman. Please check your package manager setup."
            exit 1
        }
        echo "Android Studio installed successfully."
    fi
fi

    # Verify snapd is running
    # if ! systemctl is-active --quiet snapd; then
    #     echo "Error: snapd service is not running. Please start it using 'sudo systemctl start snapd'."
    #     exit 1
    # fi

    # Install Android Studio
    

# elif[[ "$OS" == "Arch" ]]; then
#     echo "Installing Android Studio using yay..."
#     sudo pacman -S android-studio
# fi
# Install Python packages
pip3 install frida-tools objection

# Check if an Android emulator is running

read -p "Do you have an Android emulator running? (yes/no): " emulator_running
if [[ "$emulator_running" != "yes" ]]; then
    echo "Please start an Android emulator before proceeding. Exiting..."
    exit 1
fi
echo "Please start an Android emulator before proceeding."


# Get CPU architecture of the Android device
arch=$(adb shell getprop ro.product.cpu.abi)
echo "Android CPU Architecture: $arch"

# Ensure ADB root mode is enabled
echo "Please run the following command manually before proceeding:"
echo "adb root"
read -p "Press Enter after running the command..."

# Disable SELinux temporarily (requires root on device)
adb shell su -c "setenforce 0"
echo "SELinux status: $(adb shell getenforce)"  # Should return 'Permissive'

# Download and set up Frida server
mkdir -p frida
cd frida

FRIDA_VERSION="16.6.6"
FRIDA_SERVER="frida-server-$FRIDA_VERSION-android-$arch.xz"

wget "https://github.com/frida/frida/releases/download/$FRIDA_VERSION/$FRIDA_SERVER"
unxz "$FRIDA_SERVER"
chmod +x "frida-server-$FRIDA_VERSION-android-$arch"
adb push "frida-server-$FRIDA_VERSION-android-$arch" /data/local/tmp/
adb shell chmod 777 "/data/local/tmp/frida-server-$FRIDA_VERSION-android-$arch"
cd ..

## Push Frida Gadget (modify path as needed)
GADGET_SO="frida-gadget-$FRIDA_VERSION-android-$arch.so"
adb push "$GADGET_SO" /data/local/tmp/gadget.so
adb shell chmod 777 /data/local/tmp/gadget.so

# Push Burp Suite CA Certificate
adb push burp.crt /data/local/tmp/cert-der.crt

# Automatically fetch APK package name if available
apk_name=$(frida-ps -Uai | awk 'NR==2 {print $2}')
if [[ -z "$apk_name" ]]; then
    read -p "Enter the APK package name to inject Frida: " apk_name
fi

echo "Running Frida bypass command: frida -U -f $apk_name -l ./ssl_pinning.js"
frida -U -f "$apk_name" -l ./ssl_pinning.js
echo "Make sure ssl_pinning.js is in the same directory as this script."

echo "Android pentesting setup completed successfully!"