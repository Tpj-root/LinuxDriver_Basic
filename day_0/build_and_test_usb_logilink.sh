#!/bin/bash
###############################################################################
# Script Name : build_and_test_usb_logilink.sh
#
# Purpose:
#   This script automates the complete workflow for your Linux USB driver:
#
#     1. Verify that required source files exist.
#     2. Run "make" to build the kernel module.
#     3. Check whether compilation succeeded.
#     4. Remove any previously loaded copy of the module.
#     5. Insert the newly built kernel module.
#     6. Display loaded module information.
#     7. Show the last kernel log messages.
#     8. Wait for you to test USB plug/unplug events.
#     9. When you press ENTER, unload the module safely.
#
# Usage:
#
#     chmod +x build_and_test_usb_logilink.sh
#     ./build_and_test_usb_logilink.sh
#
# Requirements:
#
#     - make
#     - gcc
#     - kernel headers
#     - sudo privileges
#
###############################################################################

###############################################################################
# Exit immediately if any command fails.
#
# Without this:
#     If "make" fails, the script would continue anyway.
#
# With this enabled:
#     The script immediately stops on errors.
###############################################################################
set -e

###############################################################################
# Print a nice title.
###############################################################################
echo "========================================================="
echo "      USB LOGILINK DRIVER BUILD & TEST SCRIPT"
echo "========================================================="
echo

###############################################################################
# Verify Makefile exists.
#
# -f checks whether a regular file exists.
###############################################################################
if [ ! -f "Makefile" ]; then
    echo "ERROR: Makefile not found."
    echo "Run this script inside your driver source directory."
    exit 1
fi

###############################################################################
# Verify driver source exists.
###############################################################################
if [ ! -f "usb_logilink.c" ]; then
    echo "ERROR: usb_logilink.c not found."
    exit 1
fi

###############################################################################
# Clean previous build files.
#
# This removes:
#   *.o
#   *.mod
#   *.ko
#   Module.symvers
#   modules.order
#
# Starting from a clean state avoids stale build problems.
###############################################################################
echo "---------------------------------------------------------"
echo "Cleaning previous build..."
echo "---------------------------------------------------------"

make clean || true

###############################################################################
# Compile the kernel module.
###############################################################################
echo
echo "---------------------------------------------------------"
echo "Building kernel module..."
echo "---------------------------------------------------------"

make

###############################################################################
# Ensure the expected module exists.
###############################################################################
if [ ! -f "usb_logilink.ko" ]; then
    echo
    echo "ERROR: usb_logilink.ko was not created."
    exit 1
fi

###############################################################################
# Build successful.
###############################################################################
echo
echo "Build completed successfully."
echo

###############################################################################
# Check whether an older module is already loaded.
#
# lsmod lists loaded kernel modules.
#
# grep -q:
#   Search quietly.
#
# If found:
#   Remove it before loading the new version.
###############################################################################
if lsmod | grep -q "^usb_logilink"; then

    echo "Existing usb_logilink module detected."
    echo "Removing old module..."

    #sudo rmmod usb_logilink

    echo "Old module removed."
    echo
fi

###############################################################################
# Insert the new kernel module.
#
# insmod loads a module directly from a file.
###############################################################################
echo "---------------------------------------------------------"
echo "Loading kernel module..."
echo "---------------------------------------------------------"

sudo insmod usb_logilink.ko

echo
echo "Module loaded successfully."
echo

###############################################################################
# Display loaded module information.
#
# lsmod shows currently active kernel modules.
#
# grep filters only usb_logilink.
###############################################################################
echo "---------------------------------------------------------"
echo "Loaded module information"
echo "---------------------------------------------------------"

lsmod | grep usb_logilink || true

echo

###############################################################################
# Show recent kernel messages.
#
# dmesg contains kernel logs.
#
# tail -20 prints only the latest 20 lines.
###############################################################################
echo "---------------------------------------------------------"
echo "Recent kernel messages"
echo "---------------------------------------------------------"

dmesg | tail -20

echo

###############################################################################
# Instructions for manual testing.
###############################################################################
echo "========================================================="
echo "             DRIVER TESTING PHASE"
echo "========================================================="
echo
echo "Now plug in your USB flash drive."
echo
echo "Your driver's probe() function should execute."
echo
echo "You should see something similar in dmesg:"
echo
echo "    HELLO"
echo
echo "or whatever printk() message you added."
echo
echo "Then unplug the USB device."
echo
echo "disconnect() should execute."
echo
echo "You should see:"
echo
echo "    BYE BYE"
echo
echo "or your disconnect printk()."
echo
echo "You can monitor logs live in another terminal using:"
echo
echo "    sudo dmesg -w"
echo
echo "Press ENTER here when testing is finished."
echo

###############################################################################
# Wait until user presses ENTER.
#
# read pauses execution.
###############################################################################
read

###############################################################################
# Remove the kernel module.
#
# rmmod unloads the module from the running kernel.
###############################################################################
echo
echo "---------------------------------------------------------"
echo "Unloading kernel module..."
echo "---------------------------------------------------------"

sudo rmmod usb_logilink

echo

###############################################################################
# Confirm removal.
###############################################################################
echo "Module unloaded successfully."

echo

###############################################################################
# Show latest kernel log after unload.
###############################################################################
echo "---------------------------------------------------------"
echo "Latest kernel messages"
echo "---------------------------------------------------------"

dmesg | tail -20

echo

###############################################################################
# Finished.
###############################################################################
echo "========================================================="
echo "               ALL OPERATIONS COMPLETED"
echo "========================================================="
echo
echo "Summary:"
echo
echo "  ✓ make clean"
echo "  ✓ make"
echo "  ✓ usb_logilink.ko verified"
echo "  ✓ old module removed (if loaded)"
echo "  ✓ new module inserted"
echo "  ✓ ready for USB plug/unplug testing"
echo "  ✓ module unloaded successfully"
echo
echo "Done."
