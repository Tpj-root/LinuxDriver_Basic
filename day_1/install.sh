#!/bin/bash
#
# ==========================================================
#  LogiLink USB Auto Launcher - Installation Script
# ==========================================================
#
#  This script will:
#
#   1. Copy logilink_launcher.sh
#      -> /usr/local/bin/logilink_launcher.sh
#
#   2. Make it executable
#
#   3. Create the udev rule
#
#   4. Reload udev rules
#
#   5. Trigger udev
#
# ==========================================================

# ----------------------------------------------------------
# Check for root privileges.
#
# udev rules and /usr/local/bin require root access.
# ----------------------------------------------------------
if [ "$EUID" -ne 0 ]; then
    echo
    echo "Please run this script as root."
    echo
    echo "Example:"
    echo "    sudo ./install.sh"
    echo
    exit 1
fi

echo
echo "========================================="
echo "   LogiLink Installer"
echo "========================================="
echo

# ----------------------------------------------------------
# Verify the launcher exists.
# ----------------------------------------------------------
if [ ! -f "./logilink_launcher.sh" ]; then
    echo "ERROR:"
    echo
    echo "Cannot find:"
    echo
    echo "    ./logilink_launcher.sh"
    echo
    echo "Place this installer in the same folder."
    echo
    exit 1
fi

# ----------------------------------------------------------
# Copy launcher
# ----------------------------------------------------------
echo "[1/5] Copying launcher..."

cp ./logilink_launcher.sh \
   /usr/local/bin/logilink_launcher.sh

# ----------------------------------------------------------
# Make executable
# ----------------------------------------------------------
echo "[2/5] Setting executable permission..."

chmod +x /usr/local/bin/logilink_launcher.sh

# ----------------------------------------------------------
# Create udev rule
# ----------------------------------------------------------
echo "[3/5] Creating udev rule..."

cat >/etc/udev/rules.d/99-logilink.rules <<EOF
ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="abcd", ATTRS{idProduct}=="1234", RUN+="/usr/local/bin/logilink_launcher.sh"
EOF

# ----------------------------------------------------------
# Reload udev rules
# ----------------------------------------------------------
echo "[4/5] Reloading udev rules..."

udevadm control --reload-rules

# ----------------------------------------------------------
# Trigger udev
# ----------------------------------------------------------
echo "[5/5] Triggering udev..."

udevadm trigger

echo
echo "========================================="
echo " Installation Complete"
echo "========================================="
echo
echo "Installed launcher:"
echo
echo "    /usr/local/bin/logilink_launcher.sh"
echo
echo "Installed rule:"
echo
echo "    /etc/udev/rules.d/99-logilink.rules"
echo
echo "Now unplug and reconnect your USB device"
echo "to test the rule."
echo