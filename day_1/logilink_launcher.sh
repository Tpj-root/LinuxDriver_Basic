#!/bin/bash

# Get the logged-in user (works even when run by udev)
USER_NAME=$(who | awk '{print $1}' | head -n1)
USER_DISPLAY=$(who | awk '{print $5}' | grep -o ':[0-9]\+' | head -n1)

# Create or append to a notes file
NOTE_FILE="/home/$USER_NAME/Desktop/LogiLink_Notes.txt"

# Write timestamp when drive was connected
echo "=== Connected at $(date) ===" >> "$NOTE_FILE"
echo "Drive Vendor: abcd, Product: 1234" >> "$NOTE_FILE"
echo "" >> "$NOTE_FILE"

# Fix 1: Change ownership after creating the file
# read only mode
chown "$USER_NAME:$USER_NAME" "$NOTE_FILE"

# Launch gedit as the user (not root)
export DISPLAY=$USER_DISPLAY
export XAUTHORITY="/home/$USER_NAME/.Xauthority"


#su - "$USER_NAME" -c 'DISPLAY=:0 /usr/bin/gnome-terminal --geometry=100x30'
#su - "$USER_NAME" -c 'DISPLAY=:0 /usr/bin/gnome-terminal --geometry=100x30 -- bash -c "seq 1 10; exec bash"'
su - "$USER_NAME" -c 'DISPLAY=:0 /usr/bin/gnome-terminal --geometry=100x30 -- bash -c "sleep 5; seq 1 10; exec bash"'

# Open gedit with the notes file
su -c "DISPLAY=$USER_DISPLAY /usr/bin/gedit '$NOTE_FILE'" $USER_NAME
#bug
#su -c "DISPLAY=$USER_DISPLAY /usr/bin/gnome-terminal --geometry=100x30" "$USER_NAME"
exit 0
