#!/bin/bash

#Andriod pentesting auto step

sudo apt install python3 pip

pip install frida-tools
pip install objection

adb shell getprop ro.product.cpu.abi

adb shell su -c "setenforce 0"
adb shell getenforce  # Should return 'Permissive'
mkdir frida
cd frida
wget "https://github.com/frida/frida/releases/download/16.6.6/frida-server-16.6.6-android-x86.xz"
unzip frida-server-16.6.6-android-x86.xz
cd ..

adb push frida-gadget-16.6.6-android-x86.so /data/local/tmp/gadget.so
adb shell chmod 777 /data/local/tmp/gadget.so

