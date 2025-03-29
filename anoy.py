#!/usr/bin/env python3

import os
import subprocess
import platform
import sys

def run_command(command):
    """Run a shell command and return output."""
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error running command: {command}\n{result.stderr}")
        exit(1)
    return result.stdout.strip()

# Display author name
print("Android Pentesting Setup by FancybearIN")

# Detect OS
system = platform.system()
if system == "Linux":
    if os.path.exists("/etc/debian_version"):
        OS = "Debian"
    elif os.path.exists("/etc/arch-release"):
        OS = "Arch"
    else:
        print("Unsupported Linux distribution. Exiting.")
        exit(1)
elif system == "Windows":
    OS = "Windows"
else:
    print("Unsupported OS. Exiting.")
    exit(1)

print(f"Detected OS: {OS}")

# Inform user about the downloads
print("This script will install the following dependencies:")
print("- Python & pip\n- ADB (Android Debug Bridge)\n- Frida (for dynamic analysis)\n- Objection (for runtime security testing)\n- Android Studio\n- Required libraries for your OS")

# Normalize user input for proceeding with installation
proceed = input("Do you want to proceed with the installation? (yes/no): ").strip().lower()
if proceed != "yes":
    print("Installation aborted.")
    exit(0)

# Debug print to confirm the script is proceeding
print(f"Proceeding with installation on {OS}...")

# Install dependencies
if OS in ["Debian", "Arch"]:
    if os.path.exists("anoy.sh"):
        print("Running anoy.sh with sudo...")
        result = subprocess.run(["sudo", "bash", "anoy.sh"], capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error executing anoy.sh:\n{result.stderr}")
            print("Ensure the script is correct and has no issues.")
            exit(1)
    else:
        print("Error: anoy.sh script not found. Please ensure it is in the same directory.")
        exit(1)
elif OS == "Windows":
    print("Installing dependencies for Windows...")
    run_command("winget install --silent Python.Python.3")
    run_command("winget install --silent Google.AndroidSDK.PlatformTools")
    run_command("pip install frida-tools objection")

if OS == "Windows":
    proceed = input("Do you want to proceed with the automatic installation of Android Studio?\nPrefer manual installation? (yes/no): ").strip().lower()
    if proceed == "yes":
        run_command("winget install --silent Google.AndroidStudio")
    else:
        print("Skipping Android Studio installation. Follow the article for manual setup.")

# Install Python packages (Linux & WSL)
if OS in ["Debian", "Arch"]:
    run_command("pip3 install --user frida-tools objection")

# Ask user if an Android emulator is running
while True:
    emulator_running = input("Do you have an Android emulator running? (yes/no): ").strip().lower()
    if emulator_running == "yes":
        break
    print("Please start an Android emulator before proceeding.")

# Get CPU architecture of the Android device
arch = run_command("adb shell getprop ro.product.cpu.abi")
print(f"Android CPU Architecture: {arch}")

# Ensure ADB root mode is enabled
print("Ensuring ADB root access...")
run_command("adb root")

# Disable SELinux temporarily (requires root on device)
run_command("adb shell su -c 'setenforce 0'")
print(run_command("adb shell getenforce"))  # Should return 'Permissive'

# Download and set up Frida server
os.makedirs("frida", exist_ok=True)
os.chdir("frida")

FRIDA_VERSION = "16.6.6"
FRIDA_SERVER = f"frida-server-{FRIDA_VERSION}-android-{arch}.xz"

run_command(f"wget https://github.com/frida/frida/releases/download/{FRIDA_VERSION}/{FRIDA_SERVER}")
run_command(f"unxz {FRIDA_SERVER}")
run_command(f"chmod +x frida-server-{FRIDA_VERSION}-android-{arch}")
run_command(f"adb push frida-server-{FRIDA_VERSION}-android-{arch} /data/local/tmp/")
run_command(f"adb shell chmod 777 /data/local/tmp/frida-server-{FRIDA_VERSION}-android-{arch}")
os.chdir("..")

# Push Frida Gadget (modify path as needed)
GADGET_SO = f"frida-gadget-{FRIDA_VERSION}-android-{arch}.so"
run_command(f"adb push {GADGET_SO} /data/local/tmp/gadget.so")
run_command("adb shell chmod 777 /data/local/tmp/gadget.so")

# Push Burp Suite CA Certificate
run_command("adb push burpca-cert-der.crt /data/local/tmp/cert-der.crt")

# Automatically fetch APK package name if available
apk_name = run_command("frida-ps -Uai | awk 'NR==2 {print $2}'")
if not apk_name:
    apk_name = input("Enter the APK package name to inject Frida: ").strip()

print(f"Running Frida bypass command: frida -U -f {apk_name} -l ./ssl_pinning.js")
run_command(f"frida -U -f {apk_name} -l ./ssl_pinning.js")
print("Make sure ssl_pinning.js is in the same directory as this script.")

print("Android pentesting setup completed successfully!")
